# frozen_string_literal: true

class AddTimesheetsCustomFieldsAndCompanySwitch < ActiveRecord::Migration[8.1]
  def change
    add_column :attendance_days, :overtime_status, :string, null: false, default: "none"
    add_index :attendance_days, [ :company_id, :overtime_status ]

    create_table :custom_field_definitions do |t|
      t.references :company, null: false, foreign_key: true
      t.string :resource_type, null: false, default: "Employee"
      t.string :key, null: false
      t.string :label, null: false
      t.string :field_type, null: false, default: "text"
      t.jsonb :options, null: false, default: {}
      t.boolean :required, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :custom_field_definitions, [ :company_id, :resource_type, :key ], unique: true, name: "index_custom_field_definitions_unique"

    create_table :custom_field_values do |t|
      t.references :custom_field_definition, null: false, foreign_key: true
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.text :value
      t.timestamps
    end
    add_index :custom_field_values, [ :record_type, :record_id ]
    add_index :custom_field_values, [ :custom_field_definition_id, :record_type, :record_id ],
              unique: true, name: "index_custom_field_values_unique"
  end
end
