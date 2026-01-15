# frozen_string_literal: true

class CreateBuyerWatches < ActiveRecord::Migration[7.0]
  def change
    create_table :buyer_watches do |t|
      t.references :buyer, null: false, foreign_key: { to_table: :spree_users }
      t.references :buyer_enterprise, foreign_key: { to_table: :enterprises }

      # Location-based filtering
      t.float :latitude
      t.float :longitude
      t.decimal :radius_km, precision: 8, scale: 2, default: 50

      # Search criteria
      t.string :query_text
      t.integer :taxon_ids, array: true, default: []
      t.decimal :max_price, precision: 10, scale: 2
      t.decimal :min_quantity, precision: 12, scale: 4
      t.integer :expires_within_hours

      # Notification preferences
      t.boolean :active, default: true, null: false
      t.boolean :email_notifications, default: true
      t.datetime :last_notified_at

      t.timestamps
    end

    add_index :buyer_watches, :active
    add_index :buyer_watches, [:buyer_id, :active]
    add_index :buyer_watches, :taxon_ids, using: :gin
  end
end
