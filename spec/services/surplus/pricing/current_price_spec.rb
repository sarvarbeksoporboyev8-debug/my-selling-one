# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Surplus::Pricing::CurrentPrice do
  let(:enterprise) { create(:enterprise) }
  let(:variant) { create(:variant) }

  describe '#calculate' do
    context 'with fixed pricing strategy' do
      let(:listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               base_price: 10.0,
               pricing_strategy: 'fixed',
               expires_at: 2.days.from_now)
      end

      it 'returns base price' do
        expect(described_class.new(listing).calculate).to eq(10.0)
      end
    end

    context 'with markdown_linear pricing strategy' do
      let(:listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               base_price: 10.0,
               markdown_min_price: 5.0,
               pricing_strategy: 'markdown_linear',
               published_at: 2.days.ago,
               expires_at: 2.days.from_now)
      end

      it 'returns price between base and min based on time elapsed' do
        price = described_class.new(listing).calculate
        # At 50% through the listing period, price should be ~7.50
        expect(price).to be_between(5.0, 10.0)
      end

      it 'returns base price at start' do
        listing.update!(published_at: Time.zone.now, expires_at: 4.days.from_now)
        price = described_class.new(listing).calculate
        expect(price).to be_within(0.5).of(10.0)
      end

      it 'returns min price near expiry' do
        listing.update!(published_at: 4.days.ago, expires_at: 1.hour.from_now)
        price = described_class.new(listing).calculate
        expect(price).to be_within(0.5).of(5.0)
      end

      it 'never goes below min price' do
        listing.update!(published_at: 10.days.ago, expires_at: 1.minute.from_now)
        price = described_class.new(listing).calculate
        expect(price).to be >= 5.0
      end
    end

    context 'with markdown_steps pricing strategy' do
      let(:listing) do
        create(:surplus_listing, :active,
               enterprise: enterprise,
               variant: variant,
               base_price: 10.0,
               markdown_min_price: 4.0,
               pricing_strategy: 'markdown_steps',
               markdown_steps: [
                 { hours_remaining: 24, discount_percent: 10 },
                 { hours_remaining: 8, discount_percent: 25 },
                 { hours_remaining: 2, discount_percent: 40 }
               ],
               expires_at: 2.days.from_now)
      end

      it 'returns base price when more than 24 hours left' do
        price = described_class.new(listing).calculate
        expect(price).to eq(10.0)
      end

      it 'applies 10% discount at 24 hours' do
        listing.update!(expires_at: 20.hours.from_now)
        price = described_class.new(listing).calculate
        expect(price).to eq(9.0)
      end

      it 'applies 25% discount at 8 hours' do
        listing.update!(expires_at: 6.hours.from_now)
        price = described_class.new(listing).calculate
        expect(price).to eq(7.5)
      end

      it 'applies 40% discount at 2 hours' do
        listing.update!(expires_at: 1.hour.from_now)
        price = described_class.new(listing).calculate
        expect(price).to eq(6.0)
      end

      it 'never goes below min price' do
        listing.update!(markdown_min_price: 8.0, expires_at: 1.hour.from_now)
        price = described_class.new(listing).calculate
        expect(price).to eq(8.0)
      end

      it 'uses default steps when markdown_steps is nil' do
        listing.update!(markdown_steps: nil, expires_at: 6.hours.from_now)
        price = described_class.new(listing).calculate
        # Default: 25% off at 8 hours
        expect(price).to eq(7.5)
      end
    end
  end

  describe '#calculate_for_quantity' do
    let(:listing) do
      create(:surplus_listing, :active,
             enterprise: enterprise,
             variant: variant,
             base_price: 10.0,
             pricing_strategy: 'fixed',
             bulk_price_tiers: [
               { min_quantity: 10, discount_percent: 5 },
               { min_quantity: 50, discount_percent: 10 },
               { min_quantity: 100, discount_percent: 15 }
             ],
             expires_at: 2.days.from_now)
    end

    it 'returns base price for small quantities' do
      price = described_class.new(listing).calculate_for_quantity(5)
      expect(price).to eq(10.0)
    end

    it 'applies 5% discount for 10+ units' do
      price = described_class.new(listing).calculate_for_quantity(25)
      expect(price).to eq(9.5)
    end

    it 'applies 10% discount for 50+ units' do
      price = described_class.new(listing).calculate_for_quantity(75)
      expect(price).to eq(9.0)
    end

    it 'applies 15% discount for 100+ units' do
      price = described_class.new(listing).calculate_for_quantity(150)
      expect(price).to eq(8.5)
    end

    it 'returns base price when no bulk tiers defined' do
      listing.update!(bulk_price_tiers: nil)
      price = described_class.new(listing).calculate_for_quantity(100)
      expect(price).to eq(10.0)
    end
  end
end
