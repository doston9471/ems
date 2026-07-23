# frozen_string_literal: true

class CreateEmployeeDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :employee_documents do |t|
      t.references :company, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.string :doc_type, null: false, default: "other"
      t.string :title, null: false
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :employee_documents, [ :company_id, :doc_type ]
    add_index :employee_documents, [ :employee_id, :doc_type ]
  end
end
