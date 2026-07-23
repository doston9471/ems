# frozen_string_literal: true

class ReviewFeedback < ApplicationRecord
  belongs_to :performance_review
  belongs_to :author_employee, class_name: "Employee"

  validates :body, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validate :author_same_company

  private

  def author_same_company
    return if author_employee.blank? || performance_review.blank?
    return if author_employee.company_id == performance_review.company_id

    errors.add(:author_employee, "must belong to the same company")
  end
end
