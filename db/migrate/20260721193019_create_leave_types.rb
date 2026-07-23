# frozen_string_literal: true

class CreateLeaveTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :leave_types do |t|
      t.references :company, null: false, foreign_key: true
      t.string :key, null: false
      t.string :name, null: false
      t.boolean :paid, null: false, default: true
      t.boolean :requires_manager, null: false, default: true
      t.boolean :requires_hr, null: false, default: true
      t.string :color

      t.timestamps
    end

    add_index :leave_types, [ :company_id, :key ], unique: true
  end
end
