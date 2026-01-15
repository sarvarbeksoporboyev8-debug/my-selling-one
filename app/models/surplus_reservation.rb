# frozen_string_literal: true

class SurplusReservation < ApplicationRecord
  STATUSES = %w[active expired cancelled converted].freeze

  # Associations
  belongs_to :surplus_listing
  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :buyer_enterprise, class_name: 'Enterprise', optional: true
  belongs_to :order, class_name: 'Spree::Order', optional: true

  has_one :surplus_offer

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price_at_reservation, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_until, presence: true
  validates :status, inclusion: { in: STATUSES }

  validate :quantity_within_listing_bounds

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :expired_holds, -> {
    where(status: 'active')
      .where('reserved_until < ?', Time.zone.now)
  }
  scope :for_buyer, ->(buyer_id) { where(buyer_id: buyer_id) }
  scope :for_listing, ->(listing_id) { where(surplus_listing_id: listing_id) }

  # Callbacks
  after_create :notify_seller

  # Instance methods
  def expired?
    reserved_until < Time.zone.now
  end

  def time_remaining_seconds
    return 0 if expired?

    (reserved_until - Time.zone.now).to_i
  end

  def total_price
    quantity * price_at_reservation
  end

  def cancel!
    return false unless status == 'active'

    transaction do
      Surplus::Listings::ReleaseReservation.new(self).call
    end
    true
  end

  def expire!
    return false unless status == 'active'

    transaction do
      Surplus::Listings::ReleaseReservation.new(self).call
      update!(status: 'expired')
    end
    true
  end

  def convert_to_order!
    return false unless status == 'active'
    return false if expired?

    # Stub for full Spree::Order integration
    # This would create a Spree::Order with the reserved items
    update!(status: 'converted')
    record_completion_metric
    true
  end

  def seller_enterprise
    surplus_listing.enterprise
  end

  private

  def quantity_within_listing_bounds
    return if surplus_listing.blank? || quantity.blank?

    min_qty = surplus_listing.min_order_quantity || 0
    if quantity < min_qty
      errors.add(:quantity, "must be at least #{min_qty} #{surplus_listing.unit}")
    end
  end

  def notify_seller
    SurplusMailer.reservation_created_to_seller(self).deliver_later
  end

  def record_completion_metric
    SurplusMetric.create!(
      enterprise: surplus_listing.enterprise,
      surplus_listing: surplus_listing,
      metric_type: 'reservation_completed',
      quantity_kg: quantity,
      value_saved: total_price,
      recorded_on: Date.current
    )
  end
end
