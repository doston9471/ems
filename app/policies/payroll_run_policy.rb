# frozen_string_literal: true

class PayrollRunPolicy < ApplicationPolicy
  def index?
    allowed?("payroll.read")
  end

  def show?
    allowed?("payroll.read") && same_company?
  end

  def create?
    allowed?("payroll.manage")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("payroll.read")

      company_scope
    end
  end
end
