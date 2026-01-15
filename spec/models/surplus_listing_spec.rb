# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SurplusListing do
  let(:enterprise) { create(:enterprise) }
  let(:variant) { create(:variant) }

  describe 'validations' do
    subject { build(:surplus_listing, enterprise: enterprise, variant: variant) }

    it { is_expected.to validate_presence_of(:quantity_available) }
    it { is_expected.to validate_presence_of(:base_price) }
    it { is_expected.to validate_presence_of(:unit) }
    it { is_expected.to validate_presence_of(:expires_at) }
    it { is_expected.to validate_presence_of(:pickup_start_at) }
    it { is_expected.to validate_presence_of(:pickup_end_at) }

    it { is_expected.to validate_numericality_of(:quantity_available).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:base_price).is_greater_than_or_equal_to(0) }

    it { is_expected.to validate_inclusion_of(:status).in_array(SurplusListing::STATUSES) }
    it { is_expected.to validate_inclusion_of(:visibility).in_array(SurplusListing::VISIBILITY_OPTIONS) }
    it { is_expected.to validate_inclusion_of(:pricing_strategy).in_array(SurplusListing::PRICING_STRATEGIES) }

    context 'expires_at validation' do
      it 'requires expires_at to be in the future on create' do
        listing = build(:surplus_listing, enterprise: enterprise, variant: variant,
                                          expires_at: 1.hour.ago)
        expect(listing).not_to be_valid
        expect(listing.errors[:expires_at]).to include('must be in the future')
      end

      it 'allows expires_at in the future' do
        listing = build(:surplus_listing, enterprise: enterprise, variant: variant,
                                          expires_at: 2.days.from_now)
        expect(listing).to be_valid
      end
    end

    context 'pickup window validation' do
      it 'requires pickup_end_at to be after pickup_start_at' do
        listing = build(:surplus_listing, enterprise: enterprise, variant: variant,
                                          pickup_start_at: 2.days.from_now,
                                          pickup_end_at: 1.day.from_now)
        expect(listing).not_to be_valid
        expect(listing.errors[:pickup_end_at]).to include('must be after pickup start time')
      end
    end

    context 'markdown_min_price validation' do
      it 'requires markdown_min_price to be less than base_price' do
        listing = build(:surplus_listing, enterprise: enterprise, variant: variant,
                                          base_price: 10.0, markdown_min_price: 15.0)
        expect(listing).not_to be_valid
        expect(listing.errors[:markdown_min_price]).to include('must be less than or equal to base price')
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:enterprise) }
    it { is_expected.to belong_to(:variant).class_name('Spree::Variant') }
    it { is_expected.to belong_to(:pickup_address).class_name('Spree::Address').optional }
    it { is_expected.to belong_to(:created_by).class_name('Spree::User').optional }
    it { is_expected.to have_many(:surplus_reservations).dependent(:destroy) }
    it { is_expected.to have_many(:surplus_offers).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:active_listing) do
      create(:surplus_listing, :active, enterprise: enterprise, variant: variant,
                                        expires_at: 2.days.from_now, quantity_available: 100)
    end
    let!(:expired_listing) do
      create(:surplus_listing, enterprise: enterprise, variant: variant,
                               status: 'active', expires_at: 1.hour.ago, quantity_available: 50)
    end
    let!(:draft_listing) do
      create(:surplus_listing, enterprise: enterprise, variant: variant,
                               status: 'draft', expires_at: 2.days.from_now)
    end

    describe '.active' do
      it 'returns only active listings with future expiry and available quantity' do
        expect(described_class.active).to include(active_listing)
        expect(described_class.active).not_to include(expired_listing)
        expect(described_class.active).not_to include(draft_listing)
      end
    end

    describe '.expired' do
      it 'returns listings past their expiry that are not already marked expired' do
        expect(described_class.expired).to include(expired_listing)
        expect(described_class.expired).not_to include(active_listing)
      end
    end

    describe '.expiring_within' do
      let!(:soon_expiring) do
        create(:surplus_listing, :active, enterprise: enterprise, variant: variant,
                                          expires_at: 12.hours.from_now, quantity_available: 50)
      end

      it 'returns listings expiring within the specified hours' do
        expect(described_class.expiring_within(24)).to include(soon_expiring)
        expect(described_class.expiring_within(24)).not_to include(active_listing)
      end
    end
  end

  describe 'instance methods' do
    let(:listing) do
      create(:surplus_listing, :active, enterprise: enterprise, variant: variant,
                                        expires_at: 24.hours.from_now,
                                        quantity_available: 100,
                                        base_price: 10.0)
    end

    describe '#time_left_seconds' do
      it 'returns seconds until expiry' do
        expect(listing.time_left_seconds).to be_within(60).of(24 * 3600)
      end

      it 'returns 0 for expired listings' do
        listing.update_column(:expires_at, 1.hour.ago)
        expect(listing.time_left_seconds).to eq(0)
      end
    end

    describe '#time_left_hours' do
      it 'returns hours until expiry' do
        expect(listing.time_left_hours).to be_within(0.1).of(24.0)
      end
    end

    describe '#expired?' do
      it 'returns false for future expiry' do
        expect(listing.expired?).to be false
      end

      it 'returns true for past expiry' do
        listing.update_column(:expires_at, 1.hour.ago)
        expect(listing.expired?).to be true
      end
    end

    describe '#can_reserve?' do
      it 'returns true for valid reservation' do
        expect(listing.can_reserve?(50)).to be true
      end

      it 'returns false if quantity exceeds available' do
        expect(listing.can_reserve?(150)).to be false
      end

      it 'returns false if listing is expired' do
        listing.update_column(:expires_at, 1.hour.ago)
        expect(listing.can_reserve?(50)).to be false
      end

      it 'returns false if listing is not active' do
        listing.update!(status: 'cancelled')
        expect(listing.can_reserve?(50)).to be false
      end

      it 'returns false if quantity is below minimum' do
        listing.update!(min_order_quantity: 20)
        expect(listing.can_reserve?(10)).to be false
      end
    end

    describe '#publish!' do
      let(:draft_listing) do
        create(:surplus_listing, enterprise: enterprise, variant: variant,
                                 status: 'draft', expires_at: 2.days.from_now)
      end

      it 'changes status to active' do
        expect { draft_listing.publish! }.to change { draft_listing.status }.from('draft').to('active')
      end

      it 'sets published_at' do
        draft_listing.publish!
        expect(draft_listing.published_at).to be_present
      end

      it 'enqueues NotifyWatchersJob' do
        expect {
          draft_listing.publish!
        }.to have_enqueued_job(Surplus::NotifyWatchersJob).with(draft_listing.id)
      end

      it 'returns false for non-draft listings' do
        expect(listing.publish!).to be false
      end
    end

    describe '#cancel!' do
      it 'changes status to cancelled' do
        expect { listing.cancel! }.to change { listing.status }.to('cancelled')
      end

      it 'cancels active reservations' do
        reservation = create(:surplus_reservation, surplus_listing: listing, status: 'active')
        listing.cancel!
        expect(reservation.reload.status).to eq('cancelled')
      end

      it 'cancels pending offers' do
        offer = create(:surplus_offer, surplus_listing: listing, status: 'pending')
        listing.cancel!
        expect(offer.reload.status).to eq('cancelled')
      end
    end

    describe '#pickup_location' do
      it 'returns pickup_address if set' do
        address = create(:address)
        listing.update!(pickup_address: address)
        expect(listing.pickup_location).to eq(address)
      end

      it 'returns enterprise address if pickup_address not set' do
        expect(listing.pickup_location).to eq(enterprise.address)
      end
    end
  end
end
