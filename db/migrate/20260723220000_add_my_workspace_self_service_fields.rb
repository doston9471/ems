# frozen_string_literal: true

class AddMyWorkspaceSelfServiceFields < ActiveRecord::Migration[8.1]
  def change
    add_column :notification_deliveries, :read_at, :datetime
    add_index :notification_deliveries, [ :user_id, :read_at ],
              name: "index_notification_deliveries_on_user_id_and_read_at"

    add_column :users, :notification_preferences, :jsonb, null: false, default: {}
  end
end
