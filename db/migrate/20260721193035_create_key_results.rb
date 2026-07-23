# frozen_string_literal: true

class CreateKeyResults < ActiveRecord::Migration[8.1]
  def change
    create_table :key_results do |t|
      t.references :okr, null: false, foreign_key: true
      t.string :title, null: false
      t.decimal :target_value, precision: 12, scale: 2, null: false, default: 0
      t.decimal :current_value, precision: 12, scale: 2, null: false, default: 0
      t.string :unit

      t.timestamps
    end
  end
end
