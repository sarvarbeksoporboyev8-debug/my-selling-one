# frozen_string_literal: true

module Api
  module V0
    class SurplusReservationsController < Api::V0::BaseController
      include PaginationData

      before_action :require_feature_enabled
      before_action :set_reservation, only: [:show, :cancel]

      # GET /api/v0/surplus_reservations
      def index
        authorize! :read, SurplusReservation

        @reservations = SurplusReservation.for_buyer(current_api_user.id)

        # Filter by status if provided
        @reservations = @reservations.where(status: params[:status]) if params[:status].present?

        @pagy, @reservations = pagy(
          @reservations.includes(:surplus_listing).order(created_at: :desc),
          items: params[:per_page] || 20
        )

        render json: {
          surplus_reservations: ActiveModel::ArraySerializer.new(
            @reservations,
            each_serializer: Api::V0::SurplusReservationSerializer
          ),
          pagination: pagination_data
        }
      end

      # GET /api/v0/surplus_reservations/:id
      def show
        authorize! :read, @reservation

        # Users can only view their own reservations
        unless @reservation.buyer_id == current_api_user.id || can_manage_listing?
          return render json: { error: 'Not authorized' }, status: :forbidden
        end

        render json: @reservation, serializer: Api::V0::SurplusReservationSerializer
      end

      # POST /api/v0/surplus_reservations/:id/cancel
      def cancel
        authorize! :destroy, @reservation

        # Only buyer can cancel their own reservation
        unless @reservation.buyer_id == current_api_user.id
          return render json: { error: 'You can only cancel your own reservations' },
                        status: :forbidden
        end

        if @reservation.cancel!
          render json: @reservation, serializer: Api::V0::SurplusReservationSerializer
        else
          render json: { error: 'Unable to cancel reservation' }, status: :unprocessable_entity
        end
      end

      private

      def require_feature_enabled
        return if OpenFoodNetwork::FeatureToggle.enabled?(:dont_waste_surplus, current_api_user)

        render json: { error: 'Feature not enabled' }, status: :forbidden
      end

      def set_reservation
        @reservation = SurplusReservation.find(params[:id])
      end

      def can_manage_listing?
        permissions = OpenFoodNetwork::Permissions.new(current_api_user)
        permissions.editable_enterprises.include?(@reservation.surplus_listing.enterprise)
      end
    end
  end
end
