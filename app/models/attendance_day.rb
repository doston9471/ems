# frozen_string_literal: true

class AttendanceDay < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :employee

  has_many :attendance_events, dependent: :destroy

  enum :status, {
    open: "open",
    complete: "complete",
    missing_clock_out: "missing_clock_out",
    absent: "absent"
  }, validate: true

  enum :overtime_status, {
    none: "none",
    pending: "pending",
    approved: "approved",
    rejected: "rejected"
  }, validate: true, prefix: :overtime

  validates :work_date, presence: true, uniqueness: { scope: :employee_id }
  validates :worked_minutes, :overtime_minutes, :break_minutes,
            numericality: { greater_than_or_equal_to: 0 }
  validate :employee_same_company

  private

  def employee_same_company
    return if employee.blank? || employee.company_id == company_id

    errors.add(:employee, "must belong to the same company")
  end
end
