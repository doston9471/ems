# frozen_string_literal: true

class CreateDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :departments do |t|
      t.references :company, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :departments }
      t.string :name, null: false
      t.string :code
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :departments, [ :company_id, :parent_id ]
    add_index :departments, [ :company_id, :code ], unique: true, where: "code IS NOT NULL"
    add_index :departments, [ :company_id, :active ]
    add_index :departments, :name, opclass: :gin_trgm_ops, using: :gin, name: "index_departments_on_name_trgm"
  end
end
