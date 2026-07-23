# frozen_string_literal: true

class CreateInterviews < ActiveRecord::Migration[8.1]
  def change
    create_table :interviews do |t|
      t.references :applicant, null: false, foreign_key: true
      t.datetime :scheduled_at, null: false
      t.references :interviewer, null: false, foreign_key: { to_table: :employees }
      t.string :mode, null: false, default: "video"
      t.text :feedback
      t.string :status, null: false, default: "scheduled"

      t.timestamps
    end

    add_index :interviews, [ :applicant_id, :scheduled_at ]
    add_index :interviews, :status
  end
end
