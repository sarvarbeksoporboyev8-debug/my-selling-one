# frozen_string_literal: true

module Api
  module V0
    class SurplusListingSerializer < ActiveModel::Serializer
      attributes :id, :title, :description, :quality_notes,
                 :quantity_available, :quantity_original, :unit, :min_order_quantity,
                 :base_price, :currency, :pricing_strategy,
                 :markdown_min_price, :markdown_steps, :bulk_price_tiers,
                 :expires_at, :pickup_start_at, :pickup_end_at,
                 :status, :visibility, :published_at,
                 :created_at, :updated_at,
                 # Computed attributes
                 :current_price, :time_left_seconds, :time_left_hours,
                 :distance_km, :photo_urls

      has_one :enterprise, serializer: Api::V0::SurplusEnterpriseSerializer
      has_one :variant, serializer: Api::V0::SurplusVariantSerializer
      has_one :pickup_location, serializer: Api::V0::SurplusAddressSerializer

      def current_price
        object.current_price
      end

      def time_left_seconds
        object.time_left_seconds
      end

      def time_left_hours
        object.time_left_hours.round(2)
      end

      def distance_km
        # Only available if search included location filtering
        return nil unless object.respond_to?(:distance_km) && object.has_attribute?(:distance_km)

        object.distance_km&.round(2)
      end

      def pickup_location
        object.pickup_location
      end

      def photo_urls
        return [] unless object.photos.attached?

        object.photos.map do |photo|
          Rails.application.routes.url_helpers.rails_blob_url(photo, only_path: true)
        end
      rescue StandardError
        []
      end
    end

    class SurplusEnterpriseSerializer < ActiveModel::Serializer
      attributes :id, :name, :description, :latitude, :longitude,
                 :is_primary_producer, :is_distributor

      def latitude
        object.address&.latitude
      end

      def longitude
        object.address&.longitude
      end
    end

    class SurplusVariantSerializer < ActiveModel::Serializer
      attributes :id, :sku, :name, :product_name, :unit_value, :unit_description

      def name
        object.name_to_display
      end

      def product_name
        object.product&.name
      end

      def unit_value
        object.unit_value
      end

      def unit_description
        object.unit_description
      end
    end

    class SurplusAddressSerializer < ActiveModel::Serializer
      attributes :id, :address1, :address2, :city, :zipcode, :state_name,
                 :country_name, :latitude, :longitude

      def state_name
        object.state&.name
      end

      def country_name
        object.country&.name
      end
    end
  end
end
