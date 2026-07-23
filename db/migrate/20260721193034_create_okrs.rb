# frozen_string_literal: true

class CreateOkrs < ActiveRecord::Migration[8.1]
  def change
    create_table :okrs do |t|
      t.references :company, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.string :objective, null: false
      t.string :status, null: false, default: "open"
      t.integer :quarter, null: false
      t.integer :year, null: false

      t.timestamps
    end

    add_index :okrs, [ :company_id, :year, :quarter ]
    add_index :okrs, [ :employee_id, :year, :quarter ]
  end
end
