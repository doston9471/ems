# frozen_string_literal: true

class CreatePayrollRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :payroll_runs do |t|
      t.references :company, null: false, foreign_key: true
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.string :status, null: false, default: "draft"
      t.datetime :generated_at

      t.timestamps
    end

    add_index :payroll_runs, [ :company_id, :period_start, :period_end ]
    add_index :payroll_runs, [ :company_id, :status ]
  end
end
