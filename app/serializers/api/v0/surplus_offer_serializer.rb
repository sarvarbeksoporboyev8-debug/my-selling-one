# frozen_string_literal: true

module Api
  module V0
    class SurplusOfferSerializer < ActiveModel::Serializer
      attributes :id, :offered_quantity, :offered_price_per_unit, :offered_total,
                 :message, :seller_response, :status,
                 :discount_percentage, :expires_at, :responded_at,
                 :created_at, :updated_at

      has_one :surplus_listing, serializer: SurplusListingCompactSerializer
      has_one :buyer, serializer: SurplusBuyerSerializer
      has_one :buyer_enterprise, serializer: SurplusEnterpriseCompactSerializer
      has_one :surplus_reservation, serializer: SurplusReservationCompactSerializer

      def discount_percentage
        object.discount_percentage
      end
    end

    class SurplusReservationCompactSerializer < ActiveModel::Serializer
      attributes :id, :quantity, :status, :reserved_until
    end
  end
end
