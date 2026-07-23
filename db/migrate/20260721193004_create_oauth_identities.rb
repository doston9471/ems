# frozen_string_literal: true

class CreateOauthIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :oauth_identities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :email
      t.jsonb :raw_metadata, null: false, default: {}

      t.timestamps
    end

    add_index :oauth_identities, [ :provider, :uid ], unique: true
    add_index :oauth_identities, [ :user_id, :provider ], unique: true
  end
end
