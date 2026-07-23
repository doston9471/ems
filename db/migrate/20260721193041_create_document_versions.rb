# frozen_string_literal: true

class CreateDocumentVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :document_versions do |t|
      t.references :employee_document, null: false, foreign_key: true
      t.integer :version_number, null: false
      t.references :uploaded_by_user, null: false, foreign_key: { to_table: :users }
      t.text :change_note

      t.timestamps
    end

    add_index :document_versions, [ :employee_document_id, :version_number ], unique: true,
              name: "index_document_versions_on_document_and_version"
  end
end
