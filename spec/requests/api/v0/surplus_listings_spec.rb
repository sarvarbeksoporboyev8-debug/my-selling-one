# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Api::V0::SurplusListings', type: :request do
  include AuthenticationHelper

  let(:enterprise) { create(:enterprise) }
  let(:variant) { create(:variant, product: create(:product, supplier: enterprise)) }
  let(:user) { create(:user) }
  let(:enterprise_owner) { enterprise.owner }

  before do
    allow(OpenFoodNetwork::FeatureToggle).to receive(:enabled?)
      .with(:dont_waste_surplus, anything).and_return(true)
  end

  describe 'GET /api/v0/surplus_listings' do
    let!(:active_listing) do
      create(:surplus_listing, :active,
             enterprise: enterprise,
             variant: variant,
             quantity_available: 100,
             expires_at: 2.days.from_now)
    end

    let!(:draft_listing) do
      create(:surplus_listing,
             enterprise: enterprise,
             variant: variant,
             status: 'draft',
             expires_at: 2.days.from_now)
    end

    context 'as anonymous user' do
      it 'returns available listings' do
        get '/api/v0/surplus_listings'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['surplus_listings'].length).to eq(1)
        expect(json['surplus_listings'].first['id']).to eq(active_listing.id)
      end

      it 'does not return draft listings' do
        get '/api/v0/surplus_listings'

        json = JSON.parse(response.body)
        ids = json['surplus_listings'].map { |l| l['id'] }
        expect(ids).not_to include(draft_listing.id)
      end
    end

    context 'with filters' do
      it 'filters by price range' do
        get '/api/v0/surplus_listings', params: { min_price: 5, max_price: 15 }

        expect(response).to have_http_status(:ok)
      end

      it 'filters by text query' do
        get '/api/v0/surplus_listings', params: { query: 'tomato' }

        expect(response).to have_http_status(:ok)
      end

      it 'filters by expiry window' do
        get '/api/v0/surplus_listings', params: { expires_within_hours: 24 }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with sorting' do
      it 'sorts by price' do
        get '/api/v0/surplus_listings', params: { sort: 'price', direction: 'asc' }

        expect(response).to have_http_status(:ok)
      end

      it 'sorts by expires_at' do
        get '/api/v0/surplus_listings', params: { sort: 'expires_at' }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with pagination' do
      before do
        create_list(:surplus_listing, 25, :active,
                    enterprise: enterprise,
                    variant: variant,
                    expires_at: 2.days.from_now)
      end

      it 'returns paginated results' do
        get '/api/v0/surplus_listings', params: { per_page: 10 }

        json = JSON.parse(response.body)
        expect(json['surplus_listings'].length).to eq(10)
        expect(json['pagination']).to be_present
      end
    end

    context 'when feature is disabled' do
      before do
        allow(OpenFoodNetwork::FeatureToggle).to receive(:enabled?)
          .with(:dont_waste_surplus, anything).and_return(false)
      end

      it 'returns forbidden' do
        get '/api/v0/surplus_listings'

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /api/v0/surplus_listings/:id' do
    let!(:listing) do
      create(:surplus_listing, :active,
             enterprise: enterprise,
             variant: variant,
             expires_at: 2.days.from_now)
    end

    it 'returns the listing' do
      get "/api/v0/surplus_listings/#{listing.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(listing.id)
      expect(json['current_price']).to be_present
      expect(json['time_left_seconds']).to be_present
    end

    it 'returns 404 for non-existent listing' do
      get '/api/v0/surplus_listings/99999'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v0/surplus_listings' do
    let(:listing_params) do
      {
        surplus_listing: {
          enterprise_id: enterprise.id,
          variant_id: variant.id,
          quantity_available: 100,
          unit: 'kg',
          base_price: 10.0,
          expires_at: 2.days.from_now,
          pickup_start_at: 1.day.from_now,
          pickup_end_at: 2.days.from_now
        }
      }
    end

    context 'as enterprise owner' do
      before { login_as enterprise_owner }

      it 'creates a listing' do
        expect {
          post '/api/v0/surplus_listings', params: listing_params
        }.to change(SurplusListing, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'returns the created listing' do
        post '/api/v0/surplus_listings', params: listing_params

        json = JSON.parse(response.body)
        expect(json['quantity_available'].to_f).to eq(100.0)
        expect(json['status']).to eq('draft')
      end
    end

    context 'as non-owner' do
      before { login_as user }

      it 'returns unauthorized' do
        post '/api/v0/surplus_listings', params: listing_params

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid params' do
      before { login_as enterprise_owner }

      it 'returns validation errors' do
        post '/api/v0/surplus_listings', params: {
          surplus_listing: { enterprise_id: enterprise.id }
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /api/v0/surplus_listings/:id/publish' do
    let!(:listing) do
      create(:surplus_listing,
             enterprise: enterprise,
             variant: variant,
             status: 'draft',
             expires_at: 2.days.from_now)
    end

    context 'as enterprise owner' do
      before { login_as enterprise_owner }

      it 'publishes the listing' do
        post "/api/v0/surplus_listings/#{listing.id}/publish"

        expect(response).to have_http_status(:ok)
        expect(listing.reload.status).to eq('active')
      end

      it 'enqueues watcher notification job' do
        expect {
          post "/api/v0/surplus_listings/#{listing.id}/publish"
        }.to have_enqueued_job(Surplus::NotifyWatchersJob)
      end
    end

    context 'as non-owner' do
      before { login_as user }

      it 'returns unauthorized' do
        post "/api/v0/surplus_listings/#{listing.id}/publish"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v0/surplus_listings/:id/reserve' do
    let!(:listing) do
      create(:surplus_listing, :active,
             enterprise: enterprise,
             variant: variant,
             quantity_available: 100,
             min_order_quantity: 10,
             expires_at: 2.days.from_now)
    end

    context 'as authenticated user' do
      before { login_as user }

      it 'creates a reservation' do
        expect {
          post "/api/v0/surplus_listings/#{listing.id}/reserve",
               params: { quantity: 50 }
        }.to change(SurplusReservation, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'decrements listing quantity' do
        post "/api/v0/surplus_listings/#{listing.id}/reserve",
             params: { quantity: 50 }

        expect(listing.reload.quantity_available).to eq(50)
      end

      it 'returns the reservation' do
        post "/api/v0/surplus_listings/#{listing.id}/reserve",
             params: { quantity: 50 }

        json = JSON.parse(response.body)
        expect(json['quantity'].to_f).to eq(50.0)
        expect(json['status']).to eq('active')
        expect(json['reserved_until']).to be_present
      end

      it 'returns error for invalid quantity' do
        post "/api/v0/surplus_listings/#{listing.id}/reserve",
             params: { quantity: 5 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Minimum order quantity')
      end

      it 'returns error when quantity exceeds available' do
        post "/api/v0/surplus_listings/#{listing.id}/reserve",
             params: { quantity: 150 }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'as anonymous user' do
      it 'returns unauthorized' do
        post "/api/v0/surplus_listings/#{listing.id}/reserve",
             params: { quantity: 50 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
