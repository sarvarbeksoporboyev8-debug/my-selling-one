# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Surplus::Listings::Search do
  let(:enterprise) { create(:enterprise, :with_address) }
  let(:variant) { create(:variant) }

  describe '#call' do
    let!(:active_listing) do
      create(:surplus_listing, :active,
             enterprise: enterprise,
             variant: variant,
             quantity_available: 100,
             base_price: 10.0,
             expires_at: 2.days.from_now)
    end

    let!(:expired_listing) do
      create(:surplus_listing,
             enterprise: enterprise,
             variant: variant,
             status: 'active',
             expires_at: 1.hour.ago)
    end

    let!(:draft_listing) do
      create(:surplus_listing,
             enterprise: enterprise,
             variant: variant,
             status: 'draft',
             expires_at: 2.days.from_now)
    end

    context 'with no filters' do
      subject(:results) { described_class.new.call }

      it 'returns only available listings' do
        expect(results).to include(active_listing)
        expect(results).not_to include(expired_listing)
        expect(results).not_to include(draft_listing)
      end
    end

    context 'with text query filter' do
      let(:variant_with_name) { create(:variant, product: create(:product, name: 'Organic Tomatoes')) }
      let!(:tomato_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant_with_name,
               title: 'Fresh tomatoes',
               expires_at: 2.days.from_now)
      end

      it 'filters by product name' do
        results = described_class.new(SurplusListing.all, query: 'tomato').call
        expect(results).to include(tomato_listing)
        expect(results).not_to include(active_listing)
      end

      it 'filters by listing title' do
        results = described_class.new(SurplusListing.all, query: 'fresh').call
        expect(results).to include(tomato_listing)
      end

      it 'is case insensitive' do
        results = described_class.new(SurplusListing.all, query: 'TOMATO').call
        expect(results).to include(tomato_listing)
      end
    end

    context 'with price range filter' do
      let!(:cheap_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               base_price: 5.0,
               expires_at: 2.days.from_now)
      end

      let!(:expensive_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               base_price: 50.0,
               expires_at: 2.days.from_now)
      end

      it 'filters by minimum price' do
        results = described_class.new(SurplusListing.all, min_price: 8).call
        expect(results).to include(active_listing, expensive_listing)
        expect(results).not_to include(cheap_listing)
      end

      it 'filters by maximum price' do
        results = described_class.new(SurplusListing.all, max_price: 15).call
        expect(results).to include(active_listing, cheap_listing)
        expect(results).not_to include(expensive_listing)
      end

      it 'filters by price range' do
        results = described_class.new(SurplusListing.all, min_price: 8, max_price: 15).call
        expect(results).to include(active_listing)
        expect(results).not_to include(cheap_listing, expensive_listing)
      end
    end

    context 'with quantity range filter' do
      let!(:small_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               quantity_available: 10,
               expires_at: 2.days.from_now)
      end

      let!(:large_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               quantity_available: 500,
               expires_at: 2.days.from_now)
      end

      it 'filters by minimum quantity' do
        results = described_class.new(SurplusListing.all, min_quantity: 50).call
        expect(results).to include(active_listing, large_listing)
        expect(results).not_to include(small_listing)
      end

      it 'filters by maximum quantity' do
        results = described_class.new(SurplusListing.all, max_quantity: 200).call
        expect(results).to include(active_listing, small_listing)
        expect(results).not_to include(large_listing)
      end
    end

    context 'with expiry window filter' do
      let!(:soon_expiring) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               expires_at: 6.hours.from_now)
      end

      it 'filters by expires_within_hours' do
        results = described_class.new(SurplusListing.all, expires_within_hours: 12).call
        expect(results).to include(soon_expiring)
        expect(results).not_to include(active_listing)
      end
    end

    context 'with visibility filter' do
      let(:buyer) { create(:user) }
      let(:buyer_enterprise) { create(:enterprise) }

      let!(:public_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               visibility: 'public',
               expires_at: 2.days.from_now)
      end

      let!(:invite_only_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               visibility: 'invite_only',
               allowed_buyer_enterprise_ids: [buyer_enterprise.id],
               expires_at: 2.days.from_now)
      end

      it 'shows public listings to all' do
        results = described_class.new(SurplusListing.all, buyer_user: buyer).call
        expect(results).to include(public_listing)
      end

      it 'shows invite_only listings to allowed enterprises' do
        results = described_class.new(SurplusListing.all,
                                      buyer_user: buyer,
                                      buyer_enterprise: buyer_enterprise).call
        expect(results).to include(invite_only_listing)
      end

      it 'hides invite_only listings from non-allowed enterprises' do
        other_enterprise = create(:enterprise)
        results = described_class.new(SurplusListing.all,
                                      buyer_user: buyer,
                                      buyer_enterprise: other_enterprise).call
        expect(results).not_to include(invite_only_listing)
      end
    end

    context 'with sorting' do
      let!(:cheap_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               base_price: 5.0,
               expires_at: 1.day.from_now)
      end

      let!(:expensive_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               base_price: 50.0,
               expires_at: 3.days.from_now)
      end

      it 'sorts by price ascending' do
        results = described_class.new(SurplusListing.all, sort: 'price', direction: 'asc').call
        expect(results.first).to eq(cheap_listing)
      end

      it 'sorts by price descending' do
        results = described_class.new(SurplusListing.all, sort: 'price', direction: 'desc').call
        expect(results.first).to eq(expensive_listing)
      end

      it 'sorts by expires_at ascending (default)' do
        results = described_class.new(SurplusListing.all, sort: 'expires_at').call
        expect(results.first).to eq(cheap_listing)
      end

      it 'defaults to expires_at sorting' do
        results = described_class.new.call
        expect(results.to_sql).to include('expires_at')
      end
    end

    context 'with location filter' do
      let(:address) { create(:address, latitude: -37.8136, longitude: 144.9631) } # Melbourne
      let(:enterprise_with_location) { create(:enterprise, address: address) }

      let!(:nearby_listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise_with_location,
               variant: variant,
               expires_at: 2.days.from_now)
      end

      it 'filters by radius when coordinates provided' do
        results = described_class.new(SurplusListing.all,
                                      latitude: -37.8136,
                                      longitude: 144.9631,
                                      radius_km: 10).call
        expect(results).to include(nearby_listing)
      end

      it 'includes distance_km in results' do
        results = described_class.new(SurplusListing.all,
                                      latitude: -37.8136,
                                      longitude: 144.9631,
                                      radius_km: 10).call
        listing = results.find { |l| l.id == nearby_listing.id }
        expect(listing).to respond_to(:distance_km)
      end
    end
  end
end
