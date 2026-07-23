# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.references :company, null: false, foreign_key: true
      t.references :department, foreign_key: true
      t.string :name, null: false
      t.references :lead_employee, foreign_key: { to_table: :employees }

      t.timestamps
    end

    add_index :teams, [ :company_id, :name ]
  end
end
