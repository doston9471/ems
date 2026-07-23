# frozen_string_literal: true

class CreateLeaveApprovals < ActiveRecord::Migration[8.1]
  def change
    create_table :leave_approvals do |t|
      t.references :leave_request, null: false, foreign_key: true
      t.references :approver, null: false, foreign_key: { to_table: :users }
      t.string :step, null: false
      t.string :decision, null: false
      t.text :comment
      t.datetime :decided_at, null: false

      t.timestamps
    end

    add_index :leave_approvals, [ :leave_request_id, :step ]
  end
end
