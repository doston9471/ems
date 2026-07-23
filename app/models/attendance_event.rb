# frozen_string_literal: true

class AttendanceEvent < ApplicationRecord
  include Tenantable

  belongs_to :employee
  belongs_to :attendance_day

  enum :kind, {
    clock_in: "clock_in",
    clock_out: "clock_out",
    break_start: "break_start",
    break_end: "break_end"
  }, validate: true

  enum :source, {
    web: "web",
    mobile: "mobile",
    kiosk: "kiosk",
    import: "import",
    admin: "admin",
    graphql: "graphql"
  }, validate: true

  validates :occurred_at, presence: true
  validate :associations_same_company

  private

  def associations_same_company
    if employee.present? && employee.company_id != company_id
      errors.add(:employee, "must belong to the same company")
    end

    if attendance_day.present? && attendance_day.company_id != company_id
      errors.add(:attendance_day, "must belong to the same company")
    end
  end
end
