# frozen_string_literal: true

class BuyerWatch < ApplicationRecord
  # Associations
  belongs_to :buyer, class_name: 'Spree::User'
  belongs_to :buyer_enterprise, class_name: 'Enterprise', optional: true

  # Validations
  validates :radius_km, numericality: { greater_than: 0 }, allow_nil: true
  validates :max_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :min_quantity, numericality: { greater_than: 0 }, allow_nil: true
  validates :expires_within_hours, numericality: { greater_than: 0 }, allow_nil: true

  validate :location_requires_both_coordinates

  # Scopes
  scope :active, -> { where(active: true) }
  scope :with_email_notifications, -> { where(email_notifications: true) }
  scope :for_buyer, ->(buyer_id) { where(buyer_id: buyer_id) }

  # Instance methods
  def matches_listing?(listing)
    return false unless active?

    # Check location if specified
    if has_location_filter?
      return false unless listing_within_radius?(listing)
    end

    # Check text query
    if query_text.present?
      return false unless listing_matches_query?(listing)
    end

    # Check taxons
    if taxon_ids.present? && taxon_ids.any?
      return false unless listing_matches_taxons?(listing)
    end

    # Check price
    if max_price.present?
      return false if listing.current_price > max_price
    end

    # Check quantity
    if min_quantity.present?
      return false if listing.quantity_available < min_quantity
    end

    # Check expiry window
    if expires_within_hours.present?
      return false if listing.time_left_hours > expires_within_hours
    end

    true
  end

  def has_location_filter?
    latitude.present? && longitude.present? && radius_km.present?
  end

  def mark_notified!
    update!(last_notified_at: Time.zone.now)
  end

  private

  def location_requires_both_coordinates
    if (latitude.present? && longitude.blank?) || (latitude.blank? && longitude.present?)
      errors.add(:base, 'Both latitude and longitude must be provided for location filtering')
    end
  end

  def listing_within_radius?(listing)
    return true unless has_location_filter?

    location = listing.pickup_location
    return false if location.blank? || location.latitude.blank? || location.longitude.blank?

    distance = haversine_distance(
      latitude, longitude,
      location.latitude, location.longitude
    )

    distance <= radius_km
  end

  def listing_matches_query?(listing)
    return true if query_text.blank?

    search_text = query_text.downcase
    searchable_text = [
      listing.title,
      listing.description,
      listing.variant&.name,
      listing.variant&.product&.name,
      listing.enterprise&.name
    ].compact.join(' ').downcase

    searchable_text.include?(search_text)
  end

  def listing_matches_taxons?(listing)
    return true if taxon_ids.blank? || taxon_ids.empty?

    product_taxon_ids = listing.variant&.product&.taxons&.pluck(:id) || []
    (taxon_ids & product_taxon_ids).any?
  end

  def haversine_distance(lat1, lon1, lat2, lon2)
    # Earth's radius in kilometers
    r = 6371

    dlat = to_radians(lat2 - lat1)
    dlon = to_radians(lon2 - lon1)

    a = Math.sin(dlat / 2)**2 +
        Math.cos(to_radians(lat1)) * Math.cos(to_radians(lat2)) *
        Math.sin(dlon / 2)**2

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    r * c
  end

  def to_radians(degrees)
    degrees * Math::PI / 180
  end
end
