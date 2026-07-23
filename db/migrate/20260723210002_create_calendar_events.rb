# frozen_string_literal: true

class CreateCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_events do |t|
      t.references :company, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :external_event_id
      t.references :eventable, polymorphic: true, null: false
      t.string :status, null: false, default: "pending"
      t.jsonb :payload, null: false, default: {}
      t.text :error_message
      t.datetime :synced_at

      t.timestamps
    end

    add_index :calendar_events, [ :company_id, :provider, :status ]
    add_index :calendar_events, [ :eventable_type, :eventable_id ]
    add_index :calendar_events, [ :company_id, :created_at ]
  end
end
