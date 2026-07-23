# frozen_string_literal: true

class LeaveBalance < ApplicationRecord
  include Tenantable

  belongs_to :employee
  belongs_to :leave_type

  validates :year, presence: true,
                   numericality: { only_integer: true, greater_than_or_equal_to: 2000 }
  validates :leave_type_id, uniqueness: { scope: [ :employee_id, :year ] }
  validates :entitled, :used, numericality: { greater_than_or_equal_to: 0 }
  validate :associations_same_company

  def remaining
    entitled - used
  end

  private

  def associations_same_company
    if employee.present? && employee.company_id != company_id
      errors.add(:employee, "must belong to the same company")
    end

    if leave_type.present? && leave_type.company_id != company_id
      errors.add(:leave_type, "must belong to the same company")
    end
  end
end
