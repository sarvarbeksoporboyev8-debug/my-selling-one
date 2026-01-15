# frozen_string_literal: true

class CreateSurplusListings < ActiveRecord::Migration[7.0]
  def change
    create_table :surplus_listings do |t|
      # Core relationships
      t.references :enterprise, null: false, foreign_key: true, index: true
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.references :pickup_address, foreign_key: { to_table: :spree_addresses }
      t.references :created_by, foreign_key: { to_table: :spree_users }

      # Listing details
      t.string :title
      t.text :description
      t.text :quality_notes

      # Quantity and units
      t.decimal :quantity_available, precision: 12, scale: 4, null: false
      t.decimal :quantity_original, precision: 12, scale: 4, null: false
      t.string :unit, null: false, default: 'kg'
      t.decimal :min_order_quantity, precision: 12, scale: 4, default: 1

      # Pricing
      t.decimal :base_price, precision: 10, scale: 2, null: false
      t.string :currency, default: 'AUD'
      t.string :pricing_strategy, default: 'fixed' # fixed, markdown_linear, markdown_steps
      t.decimal :markdown_min_price, precision: 10, scale: 2
      t.jsonb :markdown_steps # For step-based markdown rules
      t.jsonb :bulk_price_tiers # For quantity-based pricing

      # Timing
      t.datetime :expires_at, null: false
      t.datetime :pickup_start_at, null: false
      t.datetime :pickup_end_at, null: false
      t.datetime :published_at

      # Status and visibility
      t.string :status, default: 'draft', null: false # draft, active, reserved, sold_out, expired, cancelled
      t.string :visibility, default: 'public', null: false # public, invite_only

      # Invite-only access control (array of enterprise IDs)
      t.integer :allowed_buyer_enterprise_ids, array: true, default: []
      t.string :allowed_buyer_tags, array: true, default: []

      t.timestamps
    end

    add_index :surplus_listings, [:enterprise_id, :status]
    add_index :surplus_listings, :expires_at
    add_index :surplus_listings, :status
    add_index :surplus_listings, :visibility
    add_index :surplus_listings, :allowed_buyer_enterprise_ids, using: :gin
    add_index :surplus_listings, :allowed_buyer_tags, using: :gin
  end
end
