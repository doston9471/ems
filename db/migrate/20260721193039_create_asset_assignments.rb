# frozen_string_literal: true

class CreateAssetAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :asset_assignments do |t|
      t.references :company_asset, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.date :assigned_on, null: false
      t.date :returned_on
      t.string :condition_on_return
      t.text :notes

      t.timestamps
    end

    add_index :asset_assignments, [ :company_asset_id, :returned_on ]
    add_index :asset_assignments, [ :employee_id, :assigned_on ]
  end
end
