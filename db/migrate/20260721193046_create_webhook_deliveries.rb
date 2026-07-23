# frozen_string_literal: true

class CreateWebhookDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_deliveries do |t|
      t.references :webhook, null: false, foreign_key: true
      t.string :event_key, null: false
      t.jsonb :payload, null: false, default: {}
      t.string :status, null: false, default: "pending"
      t.integer :response_code
      t.integer :attempts, null: false, default: 0
      t.text :error_message
      t.datetime :delivered_at

      t.timestamps
    end

    add_index :webhook_deliveries, [ :webhook_id, :event_key ]
    add_index :webhook_deliveries, [ :webhook_id, :status ]
  end
end
