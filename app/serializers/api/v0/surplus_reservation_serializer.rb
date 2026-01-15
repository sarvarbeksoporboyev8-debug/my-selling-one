# frozen_string_literal: true

module Api
  module V0
    class SurplusReservationSerializer < ActiveModel::Serializer
      attributes :id, :quantity, :price_at_reservation, :total_price,
                 :reserved_until, :status, :notes,
                 :time_remaining_seconds, :expired,
                 :created_at, :updated_at

      has_one :surplus_listing, serializer: SurplusListingCompactSerializer
      has_one :buyer, serializer: SurplusBuyerSerializer
      has_one :buyer_enterprise, serializer: SurplusEnterpriseCompactSerializer

      def total_price
        object.total_price
      end

      def time_remaining_seconds
        object.time_remaining_seconds
      end

      def expired
        object.expired?
      end
    end

    class SurplusListingCompactSerializer < ActiveModel::Serializer
      attributes :id, :title, :unit, :base_price, :current_price,
                 :expires_at, :status, :enterprise_name, :variant_name

      def current_price
        object.current_price
      end

      def enterprise_name
        object.enterprise&.name
      end

      def variant_name
        object.variant&.name_to_display
      end
    end

    class SurplusBuyerSerializer < ActiveModel::Serializer
      attributes :id, :email, :name

      def name
        "#{object.first_name} #{object.last_name}".strip
      end
    end

    class SurplusEnterpriseCompactSerializer < ActiveModel::Serializer
      attributes :id, :name
    end
  end
end
