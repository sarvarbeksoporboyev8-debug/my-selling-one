# frozen_string_literal: true

module Surplus
  class ExpireOffersJob < ApplicationJob
    queue_as :default

    def perform
      return unless feature_enabled?

      expired_count = 0

      SurplusOffer.expired_offers.find_each do |offer|
        offer.expire!
        expired_count += 1
      rescue StandardError => e
        Rails.logger.error("Failed to expire offer #{offer.id}: #{e.message}")
      end

      Rails.logger.info("Surplus::ExpireOffersJob: Expired #{expired_count} offers")
      expired_count
    end

    private

    def feature_enabled?
      OpenFoodNetwork::FeatureToggle.enabled?(:dont_waste_surplus)
    end
  end
end
