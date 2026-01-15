# frozen_string_literal: true

class SurplusOffer < ApplicationRecord
  STATUSES = %w[pending accepted rejected cancelled expired].freeze

  # Default offer expiry (in hours)
  OFFER_EXPIRY_HOURS = 24

  # Associations
  belongs_to :surplus_listing
  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :buyer_enterprise, class_name: 'Enterprise', optional: true
  belongs_to :surplus_reservation, optional: true

  # Validations
  validates :offered_quantity, presence: true, numericality: { greater_than: 0 }
  validates :offered_price_per_unit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :offered_total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: STATUSES }

  validate :quantity_within_listing_bounds
  validate :listing_must_be_active, on: :create

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :active, -> { where(status: %w[pending]) }
  scope :for_buyer, ->(buyer_id) { where(buyer_id: buyer_id) }
  scope :for_listing, ->(listing_id) { where(surplus_listing_id: listing_id) }
  scope :expired_offers, -> {
    where(status: 'pending')
      .where('expires_at < ?', Time.zone.now)
  }

  # Callbacks
  before_validation :calculate_total, on: :create
  before_create :set_expiry
  after_create :notify_seller

  # Instance methods
  def expired?
    expires_at.present? && expires_at < Time.zone.now
  end

  def accept!(response_message = nil)
    return false unless status == 'pending'
    return false if expired?
    return false unless surplus_listing.can_reserve?(offered_quantity)

    transaction do
      # Create a reservation for the accepted offer
      reservation = Surplus::Listings::Reserve.new(
        surplus_listing,
        buyer,
        offered_quantity,
        buyer_enterprise: buyer_enterprise
      ).call

      update!(
        status: 'accepted',
        seller_response: response_message,
        responded_at: Time.zone.now,
        surplus_reservation: reservation
      )

      SurplusMailer.offer_accepted_to_buyer(self).deliver_later
      record_acceptance_metric
    end
    true
  rescue StandardError => e
    errors.add(:base, e.message)
    false
  end

  def reject!(response_message = nil)
    return false unless status == 'pending'

    update!(
      status: 'rejected',
      seller_response: response_message,
      responded_at: Time.zone.now
    )

    SurplusMailer.offer_rejected_to_buyer(self).deliver_later
    true
  end

  def cancel!
    return false unless status == 'pending'

    update!(status: 'cancelled')
    true
  end

  def expire!
    return false unless status == 'pending'

    update!(status: 'expired')
    true
  end

  def seller_enterprise
    surplus_listing.enterprise
  end

  def discount_percentage
    return 0 if surplus_listing.base_price.zero?

    ((surplus_listing.base_price - offered_price_per_unit) / surplus_listing.base_price * 100).round(1)
  end

  private

  def quantity_within_listing_bounds
    return if surplus_listing.blank? || offered_quantity.blank?

    min_qty = surplus_listing.min_order_quantity || 0
    if offered_quantity < min_qty
      errors.add(:offered_quantity, "must be at least #{min_qty} #{surplus_listing.unit}")
    end

    if offered_quantity > surplus_listing.quantity_available
      errors.add(:offered_quantity, "exceeds available quantity (#{surplus_listing.quantity_available} #{surplus_listing.unit})")
    end
  end

  def listing_must_be_active
    return if surplus_listing.blank?

    unless surplus_listing.status.in?(%w[active reserved])
      errors.add(:surplus_listing, 'is not available for offers')
    end

    if surplus_listing.expired?
      errors.add(:surplus_listing, 'has expired')
    end
  end

  def calculate_total
    return if offered_quantity.blank? || offered_price_per_unit.blank?

    self.offered_total = offered_quantity * offered_price_per_unit
  end

  def set_expiry
    self.expires_at ||= Time.zone.now + OFFER_EXPIRY_HOURS.hours
  end

  def notify_seller
    SurplusMailer.offer_created_to_seller(self).deliver_later
  end

  def record_acceptance_metric
    SurplusMetric.create!(
      enterprise: surplus_listing.enterprise,
      surplus_listing: surplus_listing,
      metric_type: 'offer_accepted',
      quantity_kg: offered_quantity,
      value_saved: offered_total,
      recorded_on: Date.current,
      metadata: {
        original_price: surplus_listing.base_price,
        offered_price: offered_price_per_unit,
        discount_percentage: discount_percentage
      }
    )
  end
end
