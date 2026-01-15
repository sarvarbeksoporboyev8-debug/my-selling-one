# frozen_string_literal: true

require 'open_food_network/permissions'

module Api
  module V0
    class SurplusListingsController < Api::V0::BaseController
      include PaginationData

      skip_authorization_check only: [:index, :show]
      before_action :require_feature_enabled
      before_action :set_listing, only: [:show, :update, :destroy, :publish, :cancel, :reserve]

      # GET /api/v0/surplus_listings
      def index
        search_params = {
          buyer_user: current_api_user,
          buyer_enterprise: params[:buyer_enterprise_id].present? ? Enterprise.find_by(id: params[:buyer_enterprise_id]) : nil,
          latitude: params[:latitude],
          longitude: params[:longitude],
          radius_km: params[:radius_km],
          query: params[:query],
          taxon_ids: params[:taxon_ids],
          min_price: params[:min_price],
          max_price: params[:max_price],
          min_quantity: params[:min_quantity],
          max_quantity: params[:max_quantity],
          expires_within_hours: params[:expires_within_hours],
          pickup_date: params[:pickup_date],
          enterprise_id: params[:enterprise_id],
          sort: params[:sort],
          direction: params[:direction]
        }

        @listings = Surplus::Listings::Search.new(SurplusListing.all, search_params).call

        @pagy, @listings = pagy(@listings, items: params[:per_page] || 20)

        render json: {
          surplus_listings: ActiveModel::ArraySerializer.new(
            @listings,
            each_serializer: Api::V0::SurplusListingSerializer,
            scope: { current_user: current_api_user }
          ),
          pagination: pagination_data
        }
      end

      # GET /api/v0/surplus_listings/:id
      def show
        render json: @listing, serializer: Api::V0::SurplusListingSerializer,
               scope: { current_user: current_api_user }
      end

      # POST /api/v0/surplus_listings
      def create
        authorize! :create, SurplusListing

        enterprise = Enterprise.find(params[:surplus_listing][:enterprise_id])
        authorize_enterprise_management!(enterprise)

        @listing = SurplusListing.new(listing_params)
        @listing.created_by = current_api_user

        if @listing.save
          render json: @listing, serializer: Api::V0::SurplusListingSerializer,
                 status: :created
        else
          invalid_resource!(@listing)
        end
      end

      # PATCH/PUT /api/v0/surplus_listings/:id
      def update
        authorize! :update, @listing
        authorize_enterprise_management!(@listing.enterprise)

        if @listing.update(listing_params)
          render json: @listing, serializer: Api::V0::SurplusListingSerializer
        else
          invalid_resource!(@listing)
        end
      end

      # DELETE /api/v0/surplus_listings/:id
      def destroy
        authorize! :destroy, @listing
        authorize_enterprise_management!(@listing.enterprise)

        @listing.destroy
        head :no_content
      end

      # POST /api/v0/surplus_listings/:id/publish
      def publish
        authorize! :update, @listing
        authorize_enterprise_management!(@listing.enterprise)

        if @listing.publish!
          render json: @listing, serializer: Api::V0::SurplusListingSerializer
        else
          render json: { error: 'Unable to publish listing' }, status: :unprocessable_entity
        end
      end

      # POST /api/v0/surplus_listings/:id/cancel
      def cancel
        authorize! :update, @listing
        authorize_enterprise_management!(@listing.enterprise)

        if @listing.cancel!
          render json: @listing, serializer: Api::V0::SurplusListingSerializer
        else
          render json: { error: 'Unable to cancel listing' }, status: :unprocessable_entity
        end
      end

      # POST /api/v0/surplus_listings/:id/reserve
      def reserve
        authorize! :create, SurplusReservation

        quantity = params[:quantity].to_d
        buyer_enterprise = params[:buyer_enterprise_id].present? ?
                           Enterprise.find(params[:buyer_enterprise_id]) : nil

        reservation = Surplus::Listings::Reserve.new(
          @listing,
          current_api_user,
          quantity,
          buyer_enterprise: buyer_enterprise
        ).call

        render json: reservation, serializer: Api::V0::SurplusReservationSerializer,
               status: :created
      rescue Surplus::Listings::Reserve::ReservationError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def require_feature_enabled
        return if OpenFoodNetwork::FeatureToggle.enabled?(:dont_waste_surplus, current_api_user)

        render json: { error: 'Feature not enabled' }, status: :forbidden
      end

      def set_listing
        @listing = SurplusListing.find(params[:id])
      end

      def authorize_enterprise_management!(enterprise)
        permissions = OpenFoodNetwork::Permissions.new(current_api_user)
        return if permissions.editable_enterprises.include?(enterprise)

        raise CanCan::AccessDenied, 'You do not have permission to manage this enterprise'
      end

      def listing_params
        params.require(:surplus_listing).permit(
          :enterprise_id, :variant_id, :pickup_address_id,
          :title, :description, :quality_notes,
          :quantity_available, :unit, :min_order_quantity,
          :base_price, :currency, :pricing_strategy,
          :markdown_min_price,
          :expires_at, :pickup_start_at, :pickup_end_at,
          :visibility,
          allowed_buyer_enterprise_ids: [],
          allowed_buyer_tags: [],
          markdown_steps: [:hours_remaining, :discount_percent],
          bulk_price_tiers: [:min_quantity, :discount_percent]
        )
      end
    end
  end
end
