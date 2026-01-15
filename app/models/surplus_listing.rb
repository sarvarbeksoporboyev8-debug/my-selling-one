# frozen_string_literal: true

class SurplusListing < ApplicationRecord
  # Status enum values
  STATUSES = %w[draft active reserved sold_out expired cancelled].freeze
  VISIBILITY_OPTIONS = %w[public invite_only].freeze
  PRICING_STRATEGIES = %w[fixed markdown_linear markdown_steps].freeze

  # Default hold time for reservations (in minutes)
  RESERVATION_HOLD_MINUTES = 30

  # Associations
  belongs_to :enterprise
  belongs_to :variant, class_name: 'Spree::Variant'
  belongs_to :pickup_address, class_name: 'Spree::Address', optional: true
  belongs_to :created_by, class_name: 'Spree::User', optional: true

  has_many :surplus_reservations, dependent: :destroy
  has_many :surplus_offers, dependent: :destroy
  has_many :surplus_metrics, dependent: :nullify

  has_many_attached :photos

  # Validations
  validates :quantity_available, :quantity_original, presence: true,
                                                     numericality: { greater_than_or_equal_to: 0 }
  validates :min_order_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :markdown_min_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :unit, presence: true
  validates :expires_at, :pickup_start_at, :pickup_end_at, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :visibility, inclusion: { in: VISIBILITY_OPTIONS }
  validates :pricing_strategy, inclusion: { in: PRICING_STRATEGIES }

  validate :expires_at_must_be_future, on: :create
  validate :pickup_window_valid
  validate :markdown_min_price_less_than_base

  # Scopes
  scope :active, -> {
    where(status: %w[active reserved])
      .where('expires_at > ?', Time.zone.now)
      .where('quantity_available > 0')
  }

  scope :available, -> {
    where(status: 'active')
      .where('expires_at > ?', Time.zone.now)
      .where('quantity_available > 0')
  }

  scope :expiring_within, ->(hours) {
    where('expires_at <= ?', Time.zone.now + hours.hours)
      .where('expires_at > ?', Time.zone.now)
  }

  scope :expired, -> {
    where('expires_at <= ?', Time.zone.now)
      .where.not(status: %w[expired cancelled sold_out])
  }

  scope :visible_to_buyer, ->(buyer_user, buyer_enterprise = nil) {
    public_listings = where(visibility: 'public')

    if buyer_enterprise.present?
      invite_only = where(visibility: 'invite_only')
                    .where('? = ANY(allowed_buyer_enterprise_ids)', buyer_enterprise.id)
      public_listings.or(invite_only)
    else
      public_listings
    end
  }

  scope :by_enterprise, ->(enterprise_id) { where(enterprise_id: enterprise_id) }

  scope :for_variant, ->(variant_id) { where(variant_id: variant_id) }

  # Callbacks
  before_save :set_quantity_original, if: :new_record?
  after_create :record_creation_metric

  # Instance methods
  def time_left_seconds
    return 0 if expires_at <= Time.zone.now

    (expires_at - Time.zone.now).to_i
  end

  def time_left_hours
    time_left_seconds / 3600.0
  end

  def expired?
    expires_at <= Time.zone.now
  end

  def current_price
    Surplus::Pricing::CurrentPrice.new(self).calculate
  end

  def pickup_location
    pickup_address || enterprise.address
  end

  def can_reserve?(quantity)
    status.in?(%w[active reserved]) &&
      !expired? &&
      quantity <= quantity_available &&
      quantity >= (min_order_quantity || 0)
  end

  def publish!
    return false unless status == 'draft'
    return false if expired?

    update!(status: 'active', published_at: Time.zone.now)
    Surplus::NotifyWatchersJob.perform_later(id)
    true
  end

  def cancel!
    return false if status.in?(%w[expired cancelled sold_out])

    transaction do
      # Release all active reservations
      surplus_reservations.where(status: 'active').find_each do |reservation|
        reservation.update!(status: 'cancelled')
      end

      # Cancel pending offers
      surplus_offers.where(status: 'pending').find_each do |offer|
        offer.update!(status: 'cancelled')
      end

      update!(status: 'cancelled')
    end
    true
  end

  def mark_expired!
    return false if status.in?(%w[expired cancelled sold_out])

    update!(status: 'expired')
    record_expiration_metric
    true
  end

  def update_quantity_status!
    if quantity_available <= 0
      update!(status: 'sold_out')
    elsif quantity_available < quantity_original && status == 'active'
      update!(status: 'reserved')
    end
  end

  def quantity_reserved
    surplus_reservations.where(status: 'active').sum(:quantity)
  end

  def quantity_sold
    quantity_original - quantity_available - quantity_reserved
  end

  def seller_enterprise
    enterprise
  end

  private

  def expires_at_must_be_future
    return if expires_at.blank?

    errors.add(:expires_at, 'must be in the future') if expires_at <= Time.zone.now
  end

  def pickup_window_valid
    return if pickup_start_at.blank? || pickup_end_at.blank?

    if pickup_end_at < pickup_start_at
      errors.add(:pickup_end_at, 'must be after pickup start time')
    end
  end

  def markdown_min_price_less_than_base
    return if markdown_min_price.blank? || base_price.blank?

    if markdown_min_price > base_price
      errors.add(:markdown_min_price, 'must be less than or equal to base price')
    end
  end

  def set_quantity_original
    self.quantity_original = quantity_available if quantity_original.blank?
  end

  def record_creation_metric
    SurplusMetric.create!(
      enterprise: enterprise,
      surplus_listing: self,
      metric_type: 'listing_created',
      quantity_kg: quantity_available,
      recorded_on: Date.current
    )
  end

  def record_expiration_metric
    return if quantity_available <= 0

    SurplusMetric.create!(
      enterprise: enterprise,
      surplus_listing: self,
      metric_type: 'listing_expired',
      quantity_kg: quantity_available,
      recorded_on: Date.current,
      metadata: { wasted_quantity: quantity_available }
    )
  end
end
