# frozen_string_literal: true

class CreateSurplusReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :surplus_reservations do |t|
      t.references :surplus_listing, null: false, foreign_key: true, index: true
      t.references :buyer, null: false, foreign_key: { to_table: :spree_users }
      t.references :buyer_enterprise, foreign_key: { to_table: :enterprises }
      t.references :order, foreign_key: { to_table: :spree_orders }

      t.decimal :quantity, precision: 12, scale: 4, null: false
      t.decimal :price_at_reservation, precision: 10, scale: 2, null: false
      t.datetime :reserved_until, null: false
      t.string :status, default: 'active', null: false # active, expired, cancelled, converted

      t.text :notes

      t.timestamps
    end

    add_index :surplus_reservations, :status
    add_index :surplus_reservations, :reserved_until
    add_index :surplus_reservations, [:surplus_listing_id, :status]
    add_index :surplus_reservations, [:buyer_id, :status]
  end
end
