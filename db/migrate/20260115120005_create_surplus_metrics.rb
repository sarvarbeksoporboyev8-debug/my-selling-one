# frozen_string_literal: true

class CreateSurplusMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :surplus_metrics do |t|
      t.references :enterprise, null: false, foreign_key: true, index: true
      t.references :surplus_listing, foreign_key: true

      t.string :metric_type, null: false # listing_created, reservation_completed, offer_accepted, listing_expired
      t.decimal :quantity_kg, precision: 12, scale: 4
      t.decimal :value_saved, precision: 10, scale: 2
      t.decimal :estimated_emissions_saved_kg, precision: 10, scale: 4
      t.date :recorded_on, null: false

      t.jsonb :metadata

      t.timestamps
    end

    add_index :surplus_metrics, :metric_type
    add_index :surplus_metrics, :recorded_on
    add_index :surplus_metrics, [:enterprise_id, :recorded_on]
    add_index :surplus_metrics, [:enterprise_id, :metric_type]
  end
end
