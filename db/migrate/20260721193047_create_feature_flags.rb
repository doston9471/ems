# frozen_string_literal: true

class CreateFeatureFlags < ActiveRecord::Migration[8.1]
  def change
    create_table :feature_flags do |t|
      t.references :company, foreign_key: true
      t.string :key, null: false
      t.boolean :enabled, null: false, default: false
      t.string :description

      t.timestamps
    end

    add_index :feature_flags, [ :company_id, :key ], unique: true
    add_index :feature_flags, :key
  end
end
