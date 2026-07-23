# frozen_string_literal: true

class EmployeePolicy < ApplicationPolicy
  def index?
    allowed?("employees.read")
  end

  def show?
    allowed?("employees.read") && same_company?
  end

  def create?
    allowed?("employees.create")
  end

  def update?
    allowed?("employees.update") && same_company?
  end

  def destroy?
    allowed?("employees.delete") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("employees.read")

      company_scope
    end
  end
end
