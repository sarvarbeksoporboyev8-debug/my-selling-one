# frozen_string_literal: true

module Surplus
  class ExpireListingsJob < ApplicationJob
    queue_as :default

    def perform
      return unless feature_enabled?

      expired_count = 0

      SurplusListing.expired.find_each do |listing|
        ActiveRecord::Base.transaction do
          listing.mark_expired!

          # Notify seller
          SurplusMailer.listing_expired_to_seller(listing).deliver_later

          # Notify buyers with active reservations
          listing.surplus_reservations.where(status: 'active').find_each do |reservation|
            reservation.update!(status: 'expired')
            SurplusMailer.listing_expired_to_buyer(reservation).deliver_later
          end

          # Cancel pending offers
          listing.surplus_offers.where(status: 'pending').find_each do |offer|
            offer.update!(status: 'expired')
          end

          expired_count += 1
        end
      rescue StandardError => e
        Rails.logger.error("Failed to expire listing #{listing.id}: #{e.message}")
        Bugsnag.notify(e) if defined?(Bugsnag)
      end

      Rails.logger.info("Surplus::ExpireListingsJob: Expired #{expired_count} listings")
      expired_count
    end

    private

    def feature_enabled?
      OpenFoodNetwork::FeatureToggle.enabled?(:dont_waste_surplus)
    end
  end
end
