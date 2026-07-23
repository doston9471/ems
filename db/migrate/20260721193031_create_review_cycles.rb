# frozen_string_literal: true

class CreateReviewCycles < ActiveRecord::Migration[8.1]
  def change
    create_table :review_cycles do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.date :period_start, null: false
      t.date :period_end, null: false
      t.string :kind, null: false, default: "quarterly"
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :review_cycles, [ :company_id, :status ]
    add_index :review_cycles, [ :company_id, :period_start, :period_end ]
  end
end
