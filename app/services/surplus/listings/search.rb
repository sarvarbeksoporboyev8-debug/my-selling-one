# frozen_string_literal: true

module Surplus
  module Listings
    class Search
      SORT_OPTIONS = %w[distance expires_at price best_value created_at].freeze
      DEFAULT_SORT = 'expires_at'
      EARTH_RADIUS_KM = 6371

      def initialize(relation = SurplusListing.all, params = {})
        @relation = relation
        @params = params.with_indifferent_access
      end

      def call
        scope = @relation.available

        scope = filter_by_visibility(scope)
        scope = filter_by_location(scope)
        scope = filter_by_text(scope)
        scope = filter_by_taxons(scope)
        scope = filter_by_price_range(scope)
        scope = filter_by_quantity_range(scope)
        scope = filter_by_expiry_window(scope)
        scope = filter_by_pickup_day(scope)
        scope = filter_by_enterprise(scope)

        apply_sorting(scope)
      end

      private

      def filter_by_visibility(scope)
        buyer_user = @params[:buyer_user]
        buyer_enterprise = @params[:buyer_enterprise]

        if buyer_user.present?
          scope.visible_to_buyer(buyer_user, buyer_enterprise)
        else
          scope.where(visibility: 'public')
        end
      end

      def filter_by_location(scope)
        lat = @params[:latitude]&.to_f
        lng = @params[:longitude]&.to_f
        radius = @params[:radius_km]&.to_f

        return scope unless lat.present? && lng.present? && radius.present?

        # Join with enterprise address to get coordinates
        scope = scope.joins(enterprise: :address)
                     .where.not(spree_addresses: { latitude: nil, longitude: nil })

        # Haversine formula in SQL for distance calculation
        distance_sql = haversine_sql(lat, lng)

        scope.where("#{distance_sql} <= ?", radius)
             .select("surplus_listings.*, #{distance_sql} AS distance_km")
      end

      def filter_by_text(scope)
        query = @params[:query]&.strip
        return scope if query.blank?

        search_term = "%#{query.downcase}%"

        scope.joins(variant: :product)
             .joins(:enterprise)
             .where(
               'LOWER(surplus_listings.title) LIKE :term OR ' \
               'LOWER(surplus_listings.description) LIKE :term OR ' \
               'LOWER(spree_products.name) LIKE :term OR ' \
               'LOWER(spree_variants.sku) LIKE :term OR ' \
               'LOWER(enterprises.name) LIKE :term',
               term: search_term
             )
      end

      def filter_by_taxons(scope)
        taxon_ids = @params[:taxon_ids]
        return scope if taxon_ids.blank?

        taxon_ids = Array(taxon_ids).map(&:to_i).compact

        scope.joins(variant: { product: :taxons })
             .where(spree_taxons: { id: taxon_ids })
             .distinct
      end

      def filter_by_price_range(scope)
        min_price = @params[:min_price]&.to_f
        max_price = @params[:max_price]&.to_f

        scope = scope.where('base_price >= ?', min_price) if min_price.present?
        scope = scope.where('base_price <= ?', max_price) if max_price.present?

        scope
      end

      def filter_by_quantity_range(scope)
        min_qty = @params[:min_quantity]&.to_f
        max_qty = @params[:max_quantity]&.to_f

        scope = scope.where('quantity_available >= ?', min_qty) if min_qty.present?
        scope = scope.where('quantity_available <= ?', max_qty) if max_qty.present?

        scope
      end

      def filter_by_expiry_window(scope)
        hours = @params[:expires_within_hours]&.to_i
        return scope unless hours.present? && hours > 0

        scope.where('expires_at <= ?', Time.zone.now + hours.hours)
      end

      def filter_by_pickup_day(scope)
        pickup_date = @params[:pickup_date]
        return scope if pickup_date.blank?

        begin
          date = Date.parse(pickup_date.to_s)
          scope.where('DATE(pickup_start_at) <= ? AND DATE(pickup_end_at) >= ?', date, date)
        rescue ArgumentError
          scope
        end
      end

      def filter_by_enterprise(scope)
        enterprise_id = @params[:enterprise_id]
        return scope if enterprise_id.blank?

        scope.where(enterprise_id: enterprise_id)
      end

      def apply_sorting(scope)
        sort = @params[:sort]&.to_s
        sort = DEFAULT_SORT unless SORT_OPTIONS.include?(sort)
        direction = @params[:direction]&.to_s == 'desc' ? 'DESC' : 'ASC'

        case sort
        when 'distance'
          apply_distance_sort(scope, direction)
        when 'expires_at'
          scope.order(expires_at: direction == 'ASC' ? :asc : :desc)
        when 'price'
          scope.order(base_price: direction == 'ASC' ? :asc : :desc)
        when 'best_value'
          apply_best_value_sort(scope, direction)
        when 'created_at'
          scope.order(created_at: direction == 'ASC' ? :asc : :desc)
        else
          scope.order(expires_at: :asc)
        end
      end

      def apply_distance_sort(scope, direction)
        lat = @params[:latitude]&.to_f
        lng = @params[:longitude]&.to_f

        if lat.present? && lng.present?
          distance_sql = haversine_sql(lat, lng)
          scope.joins(enterprise: :address)
               .where.not(spree_addresses: { latitude: nil, longitude: nil })
               .select("surplus_listings.*, #{distance_sql} AS distance_km")
               .order(Arel.sql("#{distance_sql} #{direction}"))
        else
          scope.order(created_at: :desc)
        end
      end

      def apply_best_value_sort(scope, direction)
        # Best value combines price per unit with time urgency
        # Lower price + sooner expiry = better value
        # Normalize both factors to 0-1 scale and combine

        scope.order(
          Arel.sql(
            "((base_price / NULLIF(quantity_available, 0)) * " \
            "(1 + (EXTRACT(EPOCH FROM (expires_at - NOW())) / 86400.0))) #{direction}"
          )
        )
      end

      def haversine_sql(lat, lng)
        # Haversine formula for calculating distance in kilometers
        <<~SQL.squish
          (#{EARTH_RADIUS_KM} * acos(
            cos(radians(#{lat})) *
            cos(radians(spree_addresses.latitude)) *
            cos(radians(spree_addresses.longitude) - radians(#{lng})) +
            sin(radians(#{lat})) *
            sin(radians(spree_addresses.latitude))
          ))
        SQL
      end
    end
  end
end
