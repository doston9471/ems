# frozen_string_literal: true

class DepartmentPolicy < ApplicationPolicy
  def index?
    allowed?("departments.read")
  end

  def show?
    allowed?("departments.read") && same_company?
  end

  def create?
    allowed?("departments.manage")
  end

  def update?
    allowed?("departments.manage") && same_company?
  end

  def destroy?
    allowed?("departments.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("departments.read")

      company_scope
    end
  end
end
