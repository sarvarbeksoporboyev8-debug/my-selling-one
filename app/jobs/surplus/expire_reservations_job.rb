# frozen_string_literal: true

module Surplus
  class ExpireReservationsJob < ApplicationJob
    queue_as :default

    def perform
      return unless feature_enabled?

      released_count = Surplus::Listings::ReleaseReservation.release_expired_reservations

      Rails.logger.info("Surplus::ExpireReservationsJob: Released #{released_count} expired reservations")
      released_count
    end

    private

    def feature_enabled?
      OpenFoodNetwork::FeatureToggle.enabled?(:dont_waste_surplus)
    end
  end
end
