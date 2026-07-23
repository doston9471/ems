# frozen_string_literal: true

class CreateCompanyAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :company_assets do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.string :asset_type, null: false, default: "other"
      t.string :serial_number
      t.string :status, null: false, default: "purchased"
      t.date :purchased_on
      t.text :notes

      t.timestamps
    end

    add_index :company_assets, [ :company_id, :status ]
    add_index :company_assets, [ :company_id, :asset_type ]
    add_index :company_assets, [ :company_id, :serial_number ], unique: true,
              where: "serial_number IS NOT NULL AND serial_number != ''",
              name: "index_company_assets_on_company_serial"
  end
end
