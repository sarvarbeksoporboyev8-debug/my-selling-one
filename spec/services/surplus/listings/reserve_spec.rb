# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Surplus::Listings::Reserve do
  let(:enterprise) { create(:enterprise) }
  let(:variant) { create(:variant) }
  let(:buyer) { create(:user) }
  let(:listing) do
    create(:surplus_listing, :active,
           enterprise: enterprise,
           variant: variant,
           quantity_available: 100,
           min_order_quantity: 10,
           base_price: 5.0,
           expires_at: 2.days.from_now)
  end

  describe '#call' do
    subject(:service) { described_class.new(listing, buyer, quantity) }

    context 'with valid reservation' do
      let(:quantity) { 50 }

      it 'creates a reservation' do
        expect { service.call }.to change(SurplusReservation, :count).by(1)
      end

      it 'returns the reservation' do
        reservation = service.call
        expect(reservation).to be_a(SurplusReservation)
        expect(reservation.quantity).to eq(50)
        expect(reservation.status).to eq('active')
      end

      it 'decrements listing quantity' do
        expect { service.call }.to change { listing.reload.quantity_available }.from(100).to(50)
      end

      it 'sets reserved_until based on hold minutes' do
        reservation = service.call
        expect(reservation.reserved_until).to be_within(1.minute).of(
          Time.zone.now + SurplusListing::RESERVATION_HOLD_MINUTES.minutes
        )
      end

      it 'captures price at reservation time' do
        reservation = service.call
        expect(reservation.price_at_reservation).to eq(listing.current_price)
      end

      it 'updates listing status to reserved when partially reserved' do
        service.call
        expect(listing.reload.status).to eq('reserved')
      end
    end

    context 'when reserving all available quantity' do
      let(:quantity) { 100 }

      it 'updates listing status to sold_out' do
        service.call
        expect(listing.reload.status).to eq('sold_out')
      end
    end

    context 'with custom hold minutes' do
      let(:quantity) { 50 }
      let(:service) { described_class.new(listing, buyer, quantity, hold_minutes: 60) }

      it 'uses custom hold time' do
        reservation = service.call
        expect(reservation.reserved_until).to be_within(1.minute).of(Time.zone.now + 60.minutes)
      end
    end

    context 'with buyer enterprise' do
      let(:quantity) { 50 }
      let(:buyer_enterprise) { create(:enterprise) }
      let(:service) { described_class.new(listing, buyer, quantity, buyer_enterprise: buyer_enterprise) }

      it 'associates buyer enterprise with reservation' do
        reservation = service.call
        expect(reservation.buyer_enterprise).to eq(buyer_enterprise)
      end
    end

    context 'with invalid quantity' do
      context 'when quantity exceeds available' do
        let(:quantity) { 150 }

        it 'raises ReservationError' do
          expect { service.call }.to raise_error(
            Surplus::Listings::Reserve::ReservationError,
            /Only 100/
          )
        end
      end

      context 'when quantity is below minimum' do
        let(:quantity) { 5 }

        it 'raises ReservationError' do
          expect { service.call }.to raise_error(
            Surplus::Listings::Reserve::ReservationError,
            /Minimum order quantity is 10/
          )
        end
      end

      context 'when quantity is zero' do
        let(:quantity) { 0 }

        it 'raises ReservationError' do
          expect { service.call }.to raise_error(
            Surplus::Listings::Reserve::ReservationError,
            /greater than zero/
          )
        end
      end
    end

    context 'with invalid listing state' do
      let(:quantity) { 50 }

      context 'when listing is expired' do
        before { listing.update_column(:expires_at, 1.hour.ago) }

        it 'raises ReservationError' do
          expect { service.call }.to raise_error(
            Surplus::Listings::Reserve::ReservationError,
            /has expired/
          )
        end
      end

      context 'when listing is cancelled' do
        before { listing.update!(status: 'cancelled') }

        it 'raises ReservationError' do
          expect { service.call }.to raise_error(
            Surplus::Listings::Reserve::ReservationError,
            /not available/
          )
        end
      end

      context 'when listing is draft' do
        before { listing.update!(status: 'draft') }

        it 'raises ReservationError' do
          expect { service.call }.to raise_error(
            Surplus::Listings::Reserve::ReservationError,
            /not available/
          )
        end
      end
    end

    context 'when buyer already has active reservation' do
      let(:quantity) { 50 }

      before do
        create(:surplus_reservation, surplus_listing: listing, buyer: buyer, status: 'active')
      end

      it 'raises ReservationError' do
        expect { service.call }.to raise_error(
          Surplus::Listings::Reserve::ReservationError,
          /already have an active reservation/
        )
      end
    end

    context 'concurrency safety' do
      let(:quantity) { 60 }

      it 'uses row locking to prevent race conditions' do
        expect(listing).to receive(:lock!).and_call_original
        service.call
      end

      it 'handles concurrent reservations safely', :aggregate_failures do
        # Simulate two concurrent reservation attempts
        threads = []
        results = []
        errors = []

        2.times do |i|
          threads << Thread.new do
            buyer = create(:user)
            begin
              result = described_class.new(listing, buyer, 60).call
              results << result
            rescue Surplus::Listings::Reserve::ReservationError => e
              errors << e
            end
          end
        end

        threads.each(&:join)

        # One should succeed, one should fail
        expect(results.size + errors.size).to eq(2)
        expect(results.size).to eq(1)
        expect(errors.size).to eq(1)
        expect(listing.reload.quantity_available).to eq(40)
      end
    end
  end
end
