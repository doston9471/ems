# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  def index?
    allowed?("teams.read")
  end

  def show?
    allowed?("teams.read") && same_company?
  end

  def create?
    allowed?("teams.manage")
  end

  def update?
    allowed?("teams.manage") && same_company?
  end

  def destroy?
    allowed?("teams.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("teams.read")

      company_scope
    end
  end
end
