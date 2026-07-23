# frozen_string_literal: true

class CreateOffices < ActiveRecord::Migration[8.1]
  def change
    create_table :offices do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.string :code
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.string :timezone
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :offices, [ :company_id, :code ], unique: true, where: "code IS NOT NULL"
    add_index :offices, [ :company_id, :active ]
  end
end
