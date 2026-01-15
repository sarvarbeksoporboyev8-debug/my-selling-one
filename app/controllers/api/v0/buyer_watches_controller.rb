# frozen_string_literal: true

module Api
  module V0
    class BuyerWatchesController < Api::V0::BaseController
      before_action :require_feature_enabled
      before_action :set_watch, only: [:show, :update, :destroy]

      # GET /api/v0/buyer_watches
      def index
        authorize! :read, BuyerWatch

        @watches = BuyerWatch.for_buyer(current_api_user.id)

        # Filter by active status if provided
        @watches = @watches.where(active: params[:active]) if params[:active].present?

        render json: {
          buyer_watches: ActiveModel::ArraySerializer.new(
            @watches.order(created_at: :desc),
            each_serializer: Api::V0::BuyerWatchSerializer
          )
        }
      end

      # GET /api/v0/buyer_watches/:id
      def show
        authorize! :read, @watch
        ensure_owner!

        render json: @watch, serializer: Api::V0::BuyerWatchSerializer
      end

      # POST /api/v0/buyer_watches
      def create
        authorize! :create, BuyerWatch

        buyer_enterprise = params[:buyer_enterprise_id].present? ?
                           Enterprise.find(params[:buyer_enterprise_id]) : nil

        @watch = BuyerWatch.new(watch_params)
        @watch.buyer = current_api_user
        @watch.buyer_enterprise = buyer_enterprise

        if @watch.save
          render json: @watch, serializer: Api::V0::BuyerWatchSerializer, status: :created
        else
          invalid_resource!(@watch)
        end
      end

      # PATCH/PUT /api/v0/buyer_watches/:id
      def update
        authorize! :update, @watch
        ensure_owner!

        if @watch.update(watch_params)
          render json: @watch, serializer: Api::V0::BuyerWatchSerializer
        else
          invalid_resource!(@watch)
        end
      end

      # DELETE /api/v0/buyer_watches/:id
      def destroy
        authorize! :destroy, @watch
        ensure_owner!

        @watch.destroy
        head :no_content
      end

      private

      def require_feature_enabled
        return if OpenFoodNetwork::FeatureToggle.enabled?(:dont_waste_surplus, current_api_user)

        render json: { error: 'Feature not enabled' }, status: :forbidden
      end

      def set_watch
        @watch = BuyerWatch.find(params[:id])
      end

      def ensure_owner!
        return if @watch.buyer_id == current_api_user.id

        render json: { error: 'Not authorized' }, status: :forbidden
      end

      def watch_params
        params.require(:buyer_watch).permit(
          :latitude, :longitude, :radius_km,
          :query_text, :max_price, :min_quantity,
          :expires_within_hours, :active, :email_notifications,
          taxon_ids: []
        )
      end
    end
  end
end
