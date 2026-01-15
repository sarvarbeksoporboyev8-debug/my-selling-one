# frozen_string_literal: true

FactoryBot.define do
  factory :surplus_listing do
    association :enterprise
    association :variant, factory: :variant

    quantity_available { 100 }
    quantity_original { 100 }
    unit { 'kg' }
    min_order_quantity { 1 }
    base_price { 10.0 }
    currency { 'AUD' }
    pricing_strategy { 'fixed' }
    status { 'draft' }
    visibility { 'public' }

    expires_at { 2.days.from_now }
    pickup_start_at { 1.day.from_now }
    pickup_end_at { 2.days.from_now }

    trait :active do
      status { 'active' }
      published_at { Time.zone.now }
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.hour.ago }
    end

    trait :with_markdown do
      pricing_strategy { 'markdown_linear' }
      markdown_min_price { 5.0 }
      published_at { 1.day.ago }
    end

    trait :with_step_markdown do
      pricing_strategy { 'markdown_steps' }
      markdown_min_price { 4.0 }
      markdown_steps do
        [
          { hours_remaining: 24, discount_percent: 10 },
          { hours_remaining: 8, discount_percent: 25 },
          { hours_remaining: 2, discount_percent: 40 }
        ]
      end
    end

    trait :with_bulk_pricing do
      bulk_price_tiers do
        [
          { min_quantity: 10, discount_percent: 5 },
          { min_quantity: 50, discount_percent: 10 },
          { min_quantity: 100, discount_percent: 15 }
        ]
      end
    end

    trait :invite_only do
      visibility { 'invite_only' }
      allowed_buyer_enterprise_ids { [] }
    end
  end

  factory :surplus_reservation do
    association :surplus_listing
    association :buyer, factory: :user

    quantity { 50 }
    price_at_reservation { 10.0 }
    reserved_until { 30.minutes.from_now }
    status { 'active' }
  end

  factory :surplus_offer do
    association :surplus_listing
    association :buyer, factory: :user

    offered_quantity { 50 }
    offered_price_per_unit { 8.0 }
    offered_total { 400.0 }
    status { 'pending' }
    expires_at { 24.hours.from_now }
  end

  factory :buyer_watch do
    association :buyer, factory: :user

    active { true }
    email_notifications { true }
    radius_km { 50 }
  end

  factory :surplus_metric do
    association :enterprise

    metric_type { 'listing_created' }
    recorded_on { Date.current }
    quantity_kg { 100 }
  end
end
