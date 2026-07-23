# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.datetime :email_verified_at
      t.boolean :mfa_enabled, null: false, default: false
      t.string :mfa_secret
      t.boolean :super_admin, null: false, default: false
      t.datetime :discarded_at
      t.string :preferred_locale

      t.timestamps
    end

    add_index :users, :email_address, unique: true
    add_index :users, :discarded_at
    add_index :users, :super_admin
  end
end
