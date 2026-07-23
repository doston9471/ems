# frozen_string_literal: true

class PayrollItemPolicy < ApplicationPolicy
  def index?
    allowed?("payroll.payslip") || allowed?("payroll.read")
  end

  def show?
    return false unless same_company_item?
    return true if allowed?("payroll.read")
    return false unless allowed?("payroll.payslip")

    employee = Employee.find_by(company_id: membership.company_id, user_id: membership.user_id)
    employee.present? && record.employee_id == employee.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if membership.blank?

      if membership.allows?("payroll.read")
        scope.joins(:payroll_run).where(payroll_runs: { company_id: membership.company_id })
      elsif membership.allows?("payroll.payslip")
        employee = Employee.find_by(company_id: membership.company_id, user_id: membership.user_id)
        return scope.none if employee.blank?

        scope.joins(:payroll_run)
             .where(employee_id: employee.id, payroll_runs: { company_id: membership.company_id })
      else
        scope.none
      end
    end
  end

  private

  def same_company_item?
    membership.present? && record.payroll_run&.company_id == membership.company_id
  end
end
