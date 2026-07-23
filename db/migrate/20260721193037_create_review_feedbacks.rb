# frozen_string_literal: true

class CreateReviewFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :review_feedbacks do |t|
      t.references :performance_review, null: false, foreign_key: true
      t.references :author_employee, null: false, foreign_key: { to_table: :employees }
      t.text :body, null: false
      t.decimal :rating, precision: 5, scale: 2

      t.timestamps
    end

    add_index :review_feedbacks, [ :performance_review_id, :author_employee_id ]
  end
end
