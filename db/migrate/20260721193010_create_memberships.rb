# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :memberships, [ :company_id, :user_id ], unique: true
    add_index :memberships, :status
  end
end
