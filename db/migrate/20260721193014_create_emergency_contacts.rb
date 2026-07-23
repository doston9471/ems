# frozen_string_literal: true

class CreateEmergencyContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :emergency_contacts do |t|
      t.references :employee, null: false, foreign_key: true
      t.string :name, null: false
      t.string :relationship
      t.string :phone
      t.string :email
      t.boolean :primary, null: false, default: false

      t.timestamps
    end

    add_index :emergency_contacts, [ :employee_id, :primary ]
  end
end
