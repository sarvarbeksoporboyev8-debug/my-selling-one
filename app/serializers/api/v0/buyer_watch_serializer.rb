# frozen_string_literal: true

module Api
  module V0
    class BuyerWatchSerializer < ActiveModel::Serializer
      attributes :id, :latitude, :longitude, :radius_km,
                 :query_text, :taxon_ids, :max_price, :min_quantity,
                 :expires_within_hours, :active, :email_notifications,
                 :last_notified_at, :created_at, :updated_at

      has_one :buyer_enterprise, serializer: SurplusEnterpriseCompactSerializer
    end
  end
end
