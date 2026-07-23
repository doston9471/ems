# frozen_string_literal: true

class CreateNotificationDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_deliveries do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.references :employee, foreign_key: true
      t.string :channel, null: false
      t.string :event_key, null: false
      t.jsonb :payload, null: false, default: {}
      t.string :status, null: false, default: "pending"
      t.text :error_message
      t.datetime :sent_at

      t.timestamps
    end

    add_index :notification_deliveries, [ :company_id, :event_key ]
    add_index :notification_deliveries, [ :company_id, :status ]
    add_index :notification_deliveries, [ :company_id, :channel ]
  end
end
