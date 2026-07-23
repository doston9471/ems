# frozen_string_literal: true

class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.references :manager, foreign_key: { to_table: :employees }
      t.references :department, foreign_key: true
      t.references :office, foreign_key: true

      t.string :employee_number, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :gender
      t.date :birthday
      t.string :nationality

      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country

      t.string :job_title
      t.bigint :salary_cents, null: false, default: 0
      t.string :currency, null: false, default: "USD"
      t.date :joining_date
      t.string :employment_status, null: false, default: "active"
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :employees, [ :company_id, :email ], unique: true
    add_index :employees, [ :company_id, :employee_number ], unique: true
    add_index :employees, :discarded_at
    add_index :employees, [ :company_id, :employment_status ]
    add_index :employees, [ :company_id, :manager_id ]
    add_index :employees, :email, opclass: :gin_trgm_ops, using: :gin, name: "index_employees_on_email_trgm"
    add_index :employees, :first_name, opclass: :gin_trgm_ops, using: :gin, name: "index_employees_on_first_name_trgm"
    add_index :employees, :last_name, opclass: :gin_trgm_ops, using: :gin, name: "index_employees_on_last_name_trgm"
  end
end
