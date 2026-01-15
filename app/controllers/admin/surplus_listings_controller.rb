# frozen_string_literal: true

require 'open_food_network/permissions'

module Admin
  class SurplusListingsController < Admin::ResourceController
    before_action :require_feature_enabled
    before_action :load_enterprises, only: [:new, :create, :edit, :update]
    before_action :load_form_data, only: [:new, :create, :edit, :update]

    def index
      @surplus_listings = editable_listings
                          .includes(:enterprise, :variant)
                          .order(created_at: :desc)
                          .page(params[:page])
                          .per(20)
    end

    def mine
      @surplus_listings = editable_listings
                          .includes(:enterprise, :variant)
                          .order(created_at: :desc)
                          .page(params[:page])
                          .per(20)

      render :index
    end

    def show
      @surplus_listing = editable_listings.find(params[:id])
      @reservations = @surplus_listing.surplus_reservations.order(created_at: :desc)
      @offers = @surplus_listing.surplus_offers.order(created_at: :desc)
    end

    def new
      @surplus_listing = SurplusListing.new
      @surplus_listing.enterprise = @enterprises.first if @enterprises.one?
    end

    def create
      @surplus_listing = SurplusListing.new(surplus_listing_params)
      @surplus_listing.created_by = spree_current_user

      authorize_enterprise!(@surplus_listing.enterprise)

      if @surplus_listing.save
        flash[:success] = 'Surplus listing created successfully'
        redirect_to admin_surplus_listing_path(@surplus_listing)
      else
        flash.now[:error] = @surplus_listing.errors.full_messages.join(', ')
        render :new
      end
    end

    def edit
      @surplus_listing = editable_listings.find(params[:id])
      authorize_enterprise!(@surplus_listing.enterprise)
    end

    def update
      @surplus_listing = editable_listings.find(params[:id])
      authorize_enterprise!(@surplus_listing.enterprise)

      if @surplus_listing.update(surplus_listing_params)
        flash[:success] = 'Surplus listing updated successfully'
        redirect_to admin_surplus_listing_path(@surplus_listing)
      else
        flash.now[:error] = @surplus_listing.errors.full_messages.join(', ')
        render :edit
      end
    end

    def destroy
      @surplus_listing = editable_listings.find(params[:id])
      authorize_enterprise!(@surplus_listing.enterprise)

      @surplus_listing.destroy
      flash[:success] = 'Surplus listing deleted'
      redirect_to admin_surplus_listings_path
    end

    def publish
      @surplus_listing = editable_listings.find(params[:id])
      authorize_enterprise!(@surplus_listing.enterprise)

      if @surplus_listing.publish!
        flash[:success] = 'Listing published successfully'
      else
        flash[:error] = 'Unable to publish listing'
      end

      redirect_to admin_surplus_listing_path(@surplus_listing)
    end

    def cancel
      @surplus_listing = editable_listings.find(params[:id])
      authorize_enterprise!(@surplus_listing.enterprise)

      if @surplus_listing.cancel!
        flash[:success] = 'Listing cancelled'
      else
        flash[:error] = 'Unable to cancel listing'
      end

      redirect_to admin_surplus_listing_path(@surplus_listing)
    end

    private

    def require_feature_enabled
      return if OpenFoodNetwork::FeatureToggle.enabled?(:dont_waste_surplus, spree_current_user)

      flash[:error] = "Don't Waste feature is not enabled"
      redirect_to admin_path
    end

    def load_enterprises
      @enterprises = editable_enterprises.order(:name)
    end

    def load_form_data
      @variants = editable_variants
      @pricing_strategies = SurplusListing::PRICING_STRATEGIES
      @visibility_options = SurplusListing::VISIBILITY_OPTIONS
      @units = %w[kg g lb oz box crate pallet unit]
    end

    def editable_enterprises
      OpenFoodNetwork::Permissions.new(spree_current_user).editable_enterprises
    end

    def editable_listings
      SurplusListing.where(enterprise: editable_enterprises)
    end

    def editable_variants
      Spree::Variant.joins(:product)
                    .where(spree_products: { supplier_id: editable_enterprises.select(:id) })
                    .includes(:product)
                    .order('spree_products.name')
    end

    def authorize_enterprise!(enterprise)
      return if enterprise.nil?
      return if editable_enterprises.include?(enterprise)

      flash[:error] = 'You do not have permission to manage this enterprise'
      redirect_to admin_surplus_listings_path
    end

    def surplus_listing_params
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
        photos: []
      )
    end
  end
end
