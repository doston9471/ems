# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.references :company, foreign_key: true
      t.string :key, null: false
      t.string :name, null: false
      t.boolean :system, null: false, default: false

      t.timestamps
    end

    add_index :roles, [ :company_id, :key ], unique: true, where: "company_id IS NOT NULL"
    add_index :roles, :key, unique: true, where: "company_id IS NULL"
    add_index :roles, :system
  end
end
