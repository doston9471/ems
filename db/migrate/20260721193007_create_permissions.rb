# frozen_string_literal: true

class CreatePermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :permissions do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.string :category, null: false

      t.timestamps
    end

    add_index :permissions, :key, unique: true
    add_index :permissions, :category
  end
end
