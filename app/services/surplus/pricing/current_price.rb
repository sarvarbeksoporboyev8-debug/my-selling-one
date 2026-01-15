# frozen_string_literal: true

module Surplus
  module Pricing
    class CurrentPrice
      # Default markdown steps if not configured on listing
      DEFAULT_MARKDOWN_STEPS = [
        { hours_remaining: 24, discount_percent: 10 },
        { hours_remaining: 8, discount_percent: 25 },
        { hours_remaining: 2, discount_percent: 40 }
      ].freeze

      def initialize(listing)
        @listing = listing
      end

      def calculate
        case @listing.pricing_strategy
        when 'fixed'
          fixed_price
        when 'markdown_linear'
          linear_markdown_price
        when 'markdown_steps'
          step_markdown_price
        else
          fixed_price
        end
      end

      # Calculate price for a specific quantity (with bulk tiers)
      def calculate_for_quantity(quantity)
        base = calculate
        tier_discount = bulk_tier_discount(quantity)

        if tier_discount > 0
          (base * (1 - tier_discount / 100.0)).round(2)
        else
          base
        end
      end

      private

      def fixed_price
        @listing.base_price
      end

      def linear_markdown_price
        return @listing.base_price if @listing.published_at.blank?

        base = @listing.base_price
        min_price = @listing.markdown_min_price || (base * 0.5)

        # Calculate progress from publish to expiry
        total_duration = @listing.expires_at - @listing.published_at
        elapsed = Time.zone.now - @listing.published_at

        return base if elapsed <= 0
        return min_price if elapsed >= total_duration

        progress = elapsed / total_duration
        price_range = base - min_price

        # Linear interpolation
        current = base - (price_range * progress)
        [current.round(2), min_price].max
      end

      def step_markdown_price
        hours_left = @listing.time_left_hours
        base = @listing.base_price
        min_price = @listing.markdown_min_price || (base * 0.5)

        steps = parse_markdown_steps

        # Find applicable discount
        applicable_discount = 0
        steps.sort_by { |s| -s[:hours_remaining] }.each do |step|
          if hours_left <= step[:hours_remaining]
            applicable_discount = step[:discount_percent]
          end
        end

        return base if applicable_discount.zero?

        discounted = base * (1 - applicable_discount / 100.0)
        [discounted.round(2), min_price].max
      end

      def parse_markdown_steps
        return DEFAULT_MARKDOWN_STEPS if @listing.markdown_steps.blank?

        steps = @listing.markdown_steps
        return DEFAULT_MARKDOWN_STEPS unless steps.is_a?(Array)

        steps.map do |step|
          {
            hours_remaining: step['hours_remaining']&.to_i || step[:hours_remaining]&.to_i,
            discount_percent: step['discount_percent']&.to_f || step[:discount_percent]&.to_f
          }
        end.select { |s| s[:hours_remaining].present? && s[:discount_percent].present? }
      end

      def bulk_tier_discount(quantity)
        return 0 if @listing.bulk_price_tiers.blank?

        tiers = @listing.bulk_price_tiers
        return 0 unless tiers.is_a?(Array)

        applicable_discount = 0

        tiers.sort_by { |t| t['min_quantity']&.to_f || t[:min_quantity]&.to_f || 0 }.each do |tier|
          min_qty = tier['min_quantity']&.to_f || tier[:min_quantity]&.to_f
          discount = tier['discount_percent']&.to_f || tier[:discount_percent]&.to_f

          if min_qty.present? && discount.present? && quantity >= min_qty
            applicable_discount = discount
          end
        end

        applicable_discount
      end
    end
  end
end
