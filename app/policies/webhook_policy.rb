# frozen_string_literal: true

class WebhookPolicy < ApplicationPolicy
  def index?
    allowed?("company.update")
  end

  def show?
    allowed?("company.update") && same_company?
  end

  def create?
    allowed?("company.update")
  end

  def update?
    allowed?("company.update") && same_company?
  end

  def destroy?
    allowed?("company.update") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("company.update")

      company_scope
    end
  end
end
