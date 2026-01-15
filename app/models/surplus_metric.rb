# frozen_string_literal: true

class SurplusMetric < ApplicationRecord
  METRIC_TYPES = %w[
    listing_created
    reservation_completed
    offer_accepted
    listing_expired
  ].freeze

  # Emissions factor: kg CO2e per kg of food waste avoided
  # Based on average food waste emissions (varies by product type)
  DEFAULT_EMISSIONS_FACTOR = 2.5

  # Associations
  belongs_to :enterprise
  belongs_to :surplus_listing, optional: true

  # Validations
  validates :metric_type, presence: true, inclusion: { in: METRIC_TYPES }
  validates :recorded_on, presence: true
  validates :quantity_kg, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :value_saved, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :for_enterprise, ->(enterprise_id) { where(enterprise_id: enterprise_id) }
  scope :for_period, ->(start_date, end_date) {
    where(recorded_on: start_date..end_date)
  }
  scope :by_type, ->(type) { where(metric_type: type) }
  scope :successful, -> { where(metric_type: %w[reservation_completed offer_accepted]) }

  # Callbacks
  before_save :calculate_emissions_saved

  # Class methods for reporting
  class << self
    def total_kg_saved(scope = all)
      scope.successful.sum(:quantity_kg) || 0
    end

    def total_value_saved(scope = all)
      scope.successful.sum(:value_saved) || 0
    end

    def total_emissions_saved(scope = all)
      scope.successful.sum(:estimated_emissions_saved_kg) || 0
    end

    def summary_for_enterprise(enterprise_id, start_date: nil, end_date: nil)
      scope = for_enterprise(enterprise_id)
      scope = scope.for_period(start_date, end_date) if start_date && end_date

      {
        total_listings: scope.by_type('listing_created').count,
        successful_transactions: scope.successful.count,
        expired_listings: scope.by_type('listing_expired').count,
        kg_saved: total_kg_saved(scope),
        value_saved: total_value_saved(scope),
        emissions_saved_kg: total_emissions_saved(scope)
      }
    end

    def global_summary(start_date: nil, end_date: nil)
      scope = all
      scope = scope.for_period(start_date, end_date) if start_date && end_date

      {
        total_listings: scope.by_type('listing_created').count,
        successful_transactions: scope.successful.count,
        expired_listings: scope.by_type('listing_expired').count,
        kg_saved: total_kg_saved(scope),
        value_saved: total_value_saved(scope),
        emissions_saved_kg: total_emissions_saved(scope),
        participating_enterprises: scope.select(:enterprise_id).distinct.count
      }
    end
  end

  private

  def calculate_emissions_saved
    return if quantity_kg.blank?
    return if metric_type.in?(%w[listing_created listing_expired])

    # Use product-specific factor if available, otherwise default
    factor = metadata&.dig('emissions_factor') || DEFAULT_EMISSIONS_FACTOR
    self.estimated_emissions_saved_kg = quantity_kg * factor
  end
end
