# frozen_string_literal: true

class CreatePerformanceReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :performance_reviews do |t|
      t.references :company, null: false, foreign_key: true
      t.references :review_cycle, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.references :reviewer, null: false, foreign_key: { to_table: :employees }
      t.string :review_type, null: false, default: "self"
      t.string :status, null: false, default: "pending"
      t.decimal :overall_rating, precision: 5, scale: 2
      t.datetime :submitted_at

      t.timestamps
    end

    add_index :performance_reviews, [ :company_id, :status ]
    add_index :performance_reviews, [ :review_cycle_id, :employee_id, :reviewer_id, :review_type ],
              unique: true, name: "index_performance_reviews_unique_assignment"
  end
end
