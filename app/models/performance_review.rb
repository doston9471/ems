# frozen_string_literal: true

class PerformanceReview < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :review_cycle
  belongs_to :employee
  belongs_to :reviewer, class_name: "Employee"

  has_many :review_feedbacks, dependent: :destroy

  enum :review_type, {
    self: "self",
    manager: "manager",
    peer_360: "peer_360"
  }, validate: true, prefix: true

  enum :status, {
    pending: "pending",
    submitted: "submitted",
    completed: "completed"
  }, validate: true

  validates :review_type, :status, presence: true
  validates :overall_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validate :associations_same_company

  private

  def associations_same_company
    {
      review_cycle: review_cycle,
      employee: employee,
      reviewer: reviewer
    }.each do |attr, record|
      next if record.blank? || record.company_id == company_id

      errors.add(attr, "must belong to the same company")
    end
  end
end
