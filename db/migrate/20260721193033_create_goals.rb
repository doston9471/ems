# frozen_string_literal: true

class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.references :company, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "open"
      t.date :target_date
      t.integer :progress_percent, null: false, default: 0

      t.timestamps
    end

    add_index :goals, [ :company_id, :status ]
    add_index :goals, [ :employee_id, :status ]
  end
end
