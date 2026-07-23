# frozen_string_literal: true

class CreateAttendanceDays < ActiveRecord::Migration[8.1]
  def change
    create_table :attendance_days do |t|
      t.references :company, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.date :work_date, null: false
      t.datetime :clock_in_at
      t.datetime :clock_out_at
      t.integer :worked_minutes, null: false, default: 0
      t.integer :overtime_minutes, null: false, default: 0
      t.integer :break_minutes, null: false, default: 0
      t.string :status, null: false, default: "open"
      t.text :notes

      t.timestamps
    end

    add_index :attendance_days, [ :employee_id, :work_date ], unique: true
    add_index :attendance_days, [ :company_id, :work_date ]
    add_index :attendance_days, [ :company_id, :status ]
  end
end
