# frozen_string_literal: true

class CreateSurplusOffers < ActiveRecord::Migration[7.0]
  def change
    create_table :surplus_offers do |t|
      t.references :surplus_listing, null: false, foreign_key: true, index: true
      t.references :buyer, null: false, foreign_key: { to_table: :spree_users }
      t.references :buyer_enterprise, foreign_key: { to_table: :enterprises }
      t.references :surplus_reservation, foreign_key: true

      t.decimal :offered_quantity, precision: 12, scale: 4, null: false
      t.decimal :offered_price_per_unit, precision: 10, scale: 2, null: false
      t.decimal :offered_total, precision: 10, scale: 2, null: false
      t.text :message
      t.text :seller_response

      t.string :status, default: 'pending', null: false # pending, accepted, rejected, cancelled, expired
      t.datetime :responded_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :surplus_offers, :status
    add_index :surplus_offers, [:surplus_listing_id, :status]
    add_index :surplus_offers, [:buyer_id, :status]
    add_index :surplus_offers, :expires_at
  end
end
