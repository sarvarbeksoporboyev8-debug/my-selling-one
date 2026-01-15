# frozen_string_literal: true

require 'open_food_network/permissions'

module Api
  module V0
    class SurplusOffersController < Api::V0::BaseController
      include PaginationData

      before_action :require_feature_enabled
      before_action :set_listing
      before_action :set_offer, only: [:show, :accept, :reject, :cancel]

      # GET /api/v0/surplus_listings/:surplus_listing_id/offers
      def index
        authorize! :read, @listing

        @offers = @listing.surplus_offers

        # Filter by status if provided
        @offers = @offers.where(status: params[:status]) if params[:status].present?

        # Sellers see all offers, buyers see only their own
        unless can_manage_listing?
          @offers = @offers.for_buyer(current_api_user.id)
        end

        @pagy, @offers = pagy(@offers.order(created_at: :desc), items: params[:per_page] || 20)

        render json: {
          surplus_offers: ActiveModel::ArraySerializer.new(
            @offers,
            each_serializer: Api::V0::SurplusOfferSerializer
          ),
          pagination: pagination_data
        }
      end

      # GET /api/v0/surplus_listings/:surplus_listing_id/offers/:id
      def show
        authorize! :read, @offer
        render json: @offer, serializer: Api::V0::SurplusOfferSerializer
      end

      # POST /api/v0/surplus_listings/:surplus_listing_id/offers
      def create
        authorize! :create, SurplusOffer

        buyer_enterprise = params[:buyer_enterprise_id].present? ?
                           Enterprise.find(params[:buyer_enterprise_id]) : nil

        @offer = @listing.surplus_offers.build(offer_params)
        @offer.buyer = current_api_user
        @offer.buyer_enterprise = buyer_enterprise

        if @offer.save
          render json: @offer, serializer: Api::V0::SurplusOfferSerializer, status: :created
        else
          invalid_resource!(@offer)
        end
      end

      # POST /api/v0/surplus_listings/:surplus_listing_id/offers/:id/accept
      def accept
        authorize! :update, @listing
        authorize_enterprise_management!(@listing.enterprise)

        if @offer.accept!(params[:response_message])
          render json: @offer, serializer: Api::V0::SurplusOfferSerializer
        else
          render json: { error: @offer.errors.full_messages.join(', ') },
                 status: :unprocessable_entity
        end
      end

      # POST /api/v0/surplus_listings/:surplus_listing_id/offers/:id/reject
      def reject
        authorize! :update, @listing
        authorize_enterprise_management!(@listing.enterprise)

        if @offer.reject!(params[:response_message])
          render json: @offer, serializer: Api::V0::SurplusOfferSerializer
        else
          render json: { error: 'Unable to reject offer' }, status: :unprocessable_entity
        end
      end

      # POST /api/v0/surplus_listings/:surplus_listing_id/offers/:id/cancel
      def cancel
        authorize! :destroy, @offer

        # Only buyer can cancel their own offer
        unless @offer.buyer_id == current_api_user.id
          return render json: { error: 'You can only cancel your own offers' },
                        status: :forbidden
        end

        if @offer.cancel!
          render json: @offer, serializer: Api::V0::SurplusOfferSerializer
        else
          render json: { error: 'Unable to cancel offer' }, status: :unprocessable_entity
        end
      end

      private

      def require_feature_enabled
        return if OpenFoodNetwork::FeatureToggle.enabled?(:dont_waste_surplus, current_api_user)

        render json: { error: 'Feature not enabled' }, status: :forbidden
      end

      def set_listing
        @listing = SurplusListing.find(params[:surplus_listing_id])
      end

      def set_offer
        @offer = @listing.surplus_offers.find(params[:id])
      end

      def can_manage_listing?
        permissions = OpenFoodNetwork::Permissions.new(current_api_user)
        permissions.editable_enterprises.include?(@listing.enterprise)
      end

      def authorize_enterprise_management!(enterprise)
        permissions = OpenFoodNetwork::Permissions.new(current_api_user)
        return if permissions.editable_enterprises.include?(enterprise)

        raise CanCan::AccessDenied, 'You do not have permission to manage this enterprise'
      end

      def offer_params
        params.require(:surplus_offer).permit(
          :offered_quantity, :offered_price_per_unit, :message
        )
      end
    end
  end
end
