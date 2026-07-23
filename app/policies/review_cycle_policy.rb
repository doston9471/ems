# frozen_string_literal: true

class ReviewCyclePolicy < ApplicationPolicy
  def index?
    allowed?("performance.read")
  end

  def show?
    allowed?("performance.read") && same_company?
  end

  def create?
    allowed?("performance.manage")
  end

  def update?
    allowed?("performance.manage") && same_company?
  end

  def assign_reviews?
    allowed?("performance.manage") && same_company?
  end

  def close?
    allowed?("performance.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("performance.read")

      company_scope
    end
  end
end
