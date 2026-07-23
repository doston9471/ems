# frozen_string_literal: true

class CreateKpis < ActiveRecord::Migration[8.1]
  def change
    create_table :kpis do |t|
      t.references :company, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :target_value, precision: 12, scale: 2, null: false, default: 0
      t.decimal :current_value, precision: 12, scale: 2, null: false, default: 0
      t.string :unit
      t.string :period, null: false

      t.timestamps
    end

    add_index :kpis, [ :company_id, :period ]
    add_index :kpis, [ :employee_id, :period ]
  end
end
