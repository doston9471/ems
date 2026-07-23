# frozen_string_literal: true

class CreateLeaveRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :leave_requests do |t|
      t.references :company, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.references :leave_type, null: false, foreign_key: true
      t.date :start_on, null: false
      t.date :end_on, null: false
      t.decimal :days, precision: 8, scale: 2, null: false
      t.text :reason
      t.string :status, null: false, default: "draft"
      t.references :manager, foreign_key: { to_table: :employees }
      t.references :hr, foreign_key: { to_table: :employees }
      t.datetime :manager_reviewed_at
      t.datetime :hr_reviewed_at
      t.text :rejection_reason

      t.timestamps
    end

    add_index :leave_requests, [ :company_id, :status ]
    add_index :leave_requests, [ :employee_id, :start_on, :end_on ]
  end
end
