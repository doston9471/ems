# frozen_string_literal: true

class CreatePayrollItems < ActiveRecord::Migration[8.1]
  def change
    create_table :payroll_items do |t|
      t.references :payroll_run, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.bigint :salary_cents, null: false, default: 0
      t.bigint :bonus_cents, null: false, default: 0
      t.bigint :commission_cents, null: false, default: 0
      t.bigint :tax_cents, null: false, default: 0
      t.bigint :insurance_cents, null: false, default: 0
      t.bigint :net_cents, null: false, default: 0
      t.string :currency, null: false, default: "USD"
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :payroll_items, [ :payroll_run_id, :employee_id ], unique: true
  end
end
