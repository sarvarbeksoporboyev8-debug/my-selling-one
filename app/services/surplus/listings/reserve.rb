# frozen_string_literal: true

module Surplus
  module Listings
    class Reserve
      class ReservationError < StandardError; end

      def initialize(listing, buyer, quantity, buyer_enterprise: nil, hold_minutes: nil)
        @listing = listing
        @buyer = buyer
        @quantity = quantity.to_d
        @buyer_enterprise = buyer_enterprise
        @hold_minutes = hold_minutes || SurplusListing::RESERVATION_HOLD_MINUTES
      end

      def call
        validate_reservation!

        reservation = nil

        ActiveRecord::Base.transaction do
          # Lock the listing row to prevent race conditions
          @listing.lock!

          # Re-validate after acquiring lock
          validate_reservation!

          # Calculate price at time of reservation
          current_price = @listing.current_price

          # Create the reservation
          reservation = SurplusReservation.create!(
            surplus_listing: @listing,
            buyer: @buyer,
            buyer_enterprise: @buyer_enterprise,
            quantity: @quantity,
            price_at_reservation: current_price,
            reserved_until: Time.zone.now + @hold_minutes.minutes,
            status: 'active'
          )

          # Decrement available quantity
          new_quantity = @listing.quantity_available - @quantity
          @listing.update!(quantity_available: new_quantity)

          # Update listing status based on remaining quantity
          @listing.update_quantity_status!
        end

        reservation
      rescue ActiveRecord::RecordInvalid => e
        raise ReservationError, e.record.errors.full_messages.join(', ')
      end

      private

      def validate_reservation!
        unless @listing.status.in?(%w[active reserved])
          raise ReservationError, 'Listing is not available for reservation'
        end

        if @listing.expired?
          raise ReservationError, 'Listing has expired'
        end

        if @quantity <= 0
          raise ReservationError, 'Quantity must be greater than zero'
        end

        min_qty = @listing.min_order_quantity || 0
        if @quantity < min_qty
          raise ReservationError, "Minimum order quantity is #{min_qty} #{@listing.unit}"
        end

        if @quantity > @listing.quantity_available
          raise ReservationError, "Only #{@listing.quantity_available} #{@listing.unit} available"
        end

        # Check if buyer already has an active reservation for this listing
        existing = SurplusReservation.where(
          surplus_listing: @listing,
          buyer: @buyer,
          status: 'active'
        ).exists?

        if existing
          raise ReservationError, 'You already have an active reservation for this listing'
        end
      end
    end
  end
end
