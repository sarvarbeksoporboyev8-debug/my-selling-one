# frozen_string_literal: true

module Surplus
  module Listings
    class ReleaseReservation
      class ReleaseError < StandardError; end

      def initialize(reservation)
        @reservation = reservation
      end

      def call
        return false unless @reservation.status == 'active'

        ActiveRecord::Base.transaction do
          listing = @reservation.surplus_listing
          listing.lock!

          # Return quantity to listing
          new_quantity = listing.quantity_available + @reservation.quantity
          listing.update!(quantity_available: new_quantity)

          # Update listing status if it was sold_out or reserved
          if listing.status.in?(%w[sold_out reserved]) && new_quantity > 0
            # Check if there are still other active reservations
            other_reservations = listing.surplus_reservations
                                        .where(status: 'active')
                                        .where.not(id: @reservation.id)
                                        .exists?

            new_status = other_reservations ? 'reserved' : 'active'
            listing.update!(status: new_status) unless listing.expired?
          end

          # Mark reservation as cancelled (or expired, depending on caller)
          @reservation.update!(status: 'cancelled') if @reservation.status == 'active'
        end

        true
      rescue ActiveRecord::RecordInvalid => e
        raise ReleaseError, e.record.errors.full_messages.join(', ')
      end

      # Class method for batch releasing expired reservations
      def self.release_expired_reservations
        released_count = 0

        SurplusReservation.expired_holds.find_each do |reservation|
          ActiveRecord::Base.transaction do
            listing = reservation.surplus_listing
            listing.lock!

            # Return quantity to listing
            new_quantity = listing.quantity_available + reservation.quantity
            listing.update!(quantity_available: new_quantity)

            # Update listing status
            if listing.status.in?(%w[sold_out reserved]) && new_quantity > 0
              other_reservations = listing.surplus_reservations
                                          .where(status: 'active')
                                          .where.not(id: reservation.id)
                                          .exists?

              new_status = other_reservations ? 'reserved' : 'active'
              listing.update!(status: new_status) unless listing.expired?
            end

            reservation.update!(status: 'expired')
            released_count += 1
          end
        rescue StandardError => e
          Rails.logger.error("Failed to release reservation #{reservation.id}: #{e.message}")
        end

        released_count
      end
    end
  end
end
