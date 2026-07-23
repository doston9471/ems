# frozen_string_literal: true

class CreateSsoConfigurations < ActiveRecord::Migration[8.1]
  def change
    create_table :sso_configurations do |t|
      t.references :company, null: false, foreign_key: true
      t.string :provider, null: false
      t.jsonb :metadata, null: false, default: {}
      t.boolean :enabled, null: false, default: false

      t.timestamps
    end

    add_index :sso_configurations, [ :company_id, :provider ], unique: true
  end
end
