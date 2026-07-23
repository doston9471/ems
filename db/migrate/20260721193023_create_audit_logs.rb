# frozen_string_literal: true

class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :company, foreign_key: true
      t.references :user, foreign_key: true
      t.string :auditable_type, null: false
      t.bigint :auditable_id, null: false
      t.string :action, null: false
      t.jsonb :changes_data, null: false, default: {}
      t.string :ip_address
      t.string :user_agent
      t.datetime :created_at, null: false
    end

    add_index :audit_logs, [ :auditable_type, :auditable_id ]
    add_index :audit_logs, [ :company_id, :created_at ]
    add_index :audit_logs, [ :user_id, :created_at ]
    add_index :audit_logs, :action
  end
end
