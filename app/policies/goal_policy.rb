# frozen_string_literal: true

class GoalPolicy < ApplicationPolicy
  def index?
    allowed?("performance.read")
  end

  def show?
    allowed?("performance.read") && same_company?
  end

  def create?
    allowed?("performance.manage")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("performance.read")

      company_scope
    end
  end
end
