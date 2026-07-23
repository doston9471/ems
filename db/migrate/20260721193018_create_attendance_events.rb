# frozen_string_literal: true

class CreateAttendanceEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :attendance_events do |t|
      t.references :company, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.references :attendance_day, null: false, foreign_key: true
      t.string :kind, null: false
      t.datetime :occurred_at, null: false
      t.string :source, null: false, default: "web"
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :attendance_events, [ :attendance_day_id, :occurred_at ]
    add_index :attendance_events, [ :company_id, :occurred_at ]
    add_index :attendance_events, :kind
  end
end
