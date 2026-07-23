# frozen_string_literal: true

class CreateApplicants < ActiveRecord::Migration[8.1]
  def change
    create_table :applicants do |t|
      t.references :company, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :stage, null: false, default: "applied"
      t.string :job_title
      t.references :department, foreign_key: true
      t.text :notes
      t.references :hired_employee, foreign_key: { to_table: :employees }

      t.timestamps
    end

    add_index :applicants, [ :company_id, :email ]
    add_index :applicants, [ :company_id, :stage ]
  end
end
