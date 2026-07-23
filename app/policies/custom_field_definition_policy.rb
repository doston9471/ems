# frozen_string_literal: true

class CustomFieldDefinitionPolicy < ApplicationPolicy
  def index?
    allowed?("company.update") || allowed?("employees.update")
  end

  def show?
    index? && same_company?
  end

  def create?
    allowed?("company.update")
  end

  def update?
    allowed?("company.update") && same_company?
  end

  def destroy?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("company.update") || membership&.allows?("employees.update")

      company_scope
    end
  end
end
