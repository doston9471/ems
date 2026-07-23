# frozen_string_literal: true

class ApplicantPolicy < ApplicationPolicy
  def index?
    allowed?("recruitment.read")
  end

  def show?
    allowed?("recruitment.read") && same_company?
  end

  def create?
    allowed?("recruitment.manage")
  end

  def update?
    allowed?("recruitment.manage") && same_company?
  end

  def hire?
    allowed?("recruitment.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("recruitment.read")

      company_scope
    end
  end
end
