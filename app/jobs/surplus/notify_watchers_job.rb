# frozen_string_literal: true

module Surplus
  class NotifyWatchersJob < ApplicationJob
    queue_as :default

    def perform(listing_id)
      return unless feature_enabled?

      listing = SurplusListing.find_by(id: listing_id)
      return unless listing&.status == 'active'

      notified_count = 0

      BuyerWatch.active.with_email_notifications.find_each do |watch|
        next unless watch.matches_listing?(listing)

        # Don't notify the seller about their own listing
        next if watch.buyer_id == listing.created_by_id

        # Don't notify too frequently (max once per hour per watch)
        if watch.last_notified_at.present? && watch.last_notified_at > 1.hour.ago
          next
        end

        SurplusMailer.listing_matches_watch(watch, listing).deliver_later
        watch.mark_notified!
        notified_count += 1
      rescue StandardError => e
        Rails.logger.error("Failed to notify watcher #{watch.id}: #{e.message}")
      end

      Rails.logger.info("Surplus::NotifyWatchersJob: Notified #{notified_count} watchers for listing #{listing_id}")
      notified_count
    end

    private

    def feature_enabled?
      OpenFoodNetwork::FeatureToggle.enabled?(:dont_waste_surplus)
    end
  end
end
