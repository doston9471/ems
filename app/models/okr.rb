# frozen_string_literal: true

class Okr < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :employee
  has_many :key_results, dependent: :destroy

  enum :status, {
    open: "open",
    in_progress: "in_progress",
    done: "done",
    cancelled: "cancelled"
  }, validate: true

  validates :objective, :quarter, :year, presence: true
  validates :quarter, inclusion: { in: 1..4 }
  validates :year, numericality: { greater_than_or_equal_to: 2000, only_integer: true }
  validate :employee_same_company

  private

  def employee_same_company
    return if employee.blank? || employee.company_id == company_id

    errors.add(:employee, "must belong to the same company")
  end
end
