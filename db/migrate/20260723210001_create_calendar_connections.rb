# frozen_string_literal: true

class CreateCalendarConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_connections do |t|
      t.references :company, null: false, foreign_key: true
      t.string :provider, null: false
      t.text :access_token
      t.text :refresh_token
      t.string :calendar_id
      t.jsonb :metadata, null: false, default: {}
      t.boolean :enabled, null: false, default: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :calendar_connections, [ :company_id, :provider ], unique: true
    add_index :calendar_connections, [ :company_id, :enabled ]
  end
end
