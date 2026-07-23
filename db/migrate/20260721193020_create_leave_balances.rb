# frozen_string_literal: true

class CreateLeaveBalances < ActiveRecord::Migration[8.1]
  def change
    create_table :leave_balances do |t|
      t.references :company, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.references :leave_type, null: false, foreign_key: true
      t.integer :year, null: false
      t.decimal :entitled, precision: 8, scale: 2, null: false, default: 0
      t.decimal :used, precision: 8, scale: 2, null: false, default: 0

      t.timestamps
    end

    add_index :leave_balances, [ :employee_id, :leave_type_id, :year ], unique: true, name: "index_leave_balances_on_employee_type_year"
    add_index :leave_balances, [ :company_id, :year ]
  end
end
