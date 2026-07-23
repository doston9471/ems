# frozen_string_literal: true

class Goal < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :employee

  enum :status, {
    open: "open",
    in_progress: "in_progress",
    done: "done",
    cancelled: "cancelled"
  }, validate: true

  validates :title, presence: true
  validates :progress_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, only_integer: true }
  validate :employee_same_company

  private

  def employee_same_company
    return if employee.blank? || employee.company_id == company_id

    errors.add(:employee, "must belong to the same company")
  end
end
