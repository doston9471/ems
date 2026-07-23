# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :timezone, null: false, default: "UTC"
      t.string :locale, null: false, default: "en"
      t.string :currency, null: false, default: "USD"
      t.string :status, null: false, default: "active"
      t.jsonb :settings, null: false, default: {}

      t.timestamps
    end

    add_index :companies, :slug, unique: true
    add_index :companies, :status
  end
end
