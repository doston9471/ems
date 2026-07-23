# frozen_string_literal: true

class PayrollItem < ApplicationRecord
  include Auditable

  belongs_to :payroll_run
  belongs_to :employee

  validates :salary_cents, :bonus_cents, :commission_cents, :tax_cents, :insurance_cents, :net_cents,
            numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :employee_id, uniqueness: { scope: :payroll_run_id }
  validate :employee_matches_run_company

  private

  def employee_matches_run_company
    return if payroll_run.blank? || employee.blank?
    return if employee.company_id == payroll_run.company_id

    errors.add(:employee, "must belong to the same company as the payroll run")
  end
end
