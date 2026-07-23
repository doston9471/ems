# frozen_string_literal: true

class PerformanceReviewPolicy < ApplicationPolicy
  def index?
    allowed?("performance.read") || allowed?("performance.review")
  end

  def show?
    (allowed?("performance.read") || allowed?("performance.review") || reviewer?) && same_company?
  end

  def submit?
    (allowed?("performance.review") || reviewer?) && same_company? && record.pending?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none if membership.blank?

      if membership.allows?("performance.read") || membership.allows?("performance.manage")
        company_scope
      elsif membership.allows?("performance.review")
        employee = employee_for_membership
        return scope.none if employee.blank?

        company_scope.where(reviewer_id: employee.id).or(
          company_scope.where(employee_id: employee.id)
        )
      else
        scope.none
      end
    end

    private

    def employee_for_membership
      Employee.find_by(company_id: membership.company_id, user_id: membership.user_id)
    end
  end

  private

  def reviewer?
    employee = Employee.find_by(company_id: membership.company_id, user_id: membership.user_id)
    return false if employee.blank?

    record.reviewer_id == employee.id
  end
end
