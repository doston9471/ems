# frozen_string_literal: true

class OfficePolicy < ApplicationPolicy
  def index?
    allowed?("offices.read")
  end

  def show?
    allowed?("offices.read") && same_company?
  end

  def create?
    allowed?("offices.manage")
  end

  def update?
    allowed?("offices.manage") && same_company?
  end

  def destroy?
    allowed?("offices.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("offices.read")

      company_scope
    end
  end
end
