# frozen_string_literal: true

class LeaveRequestPolicy < ApplicationPolicy
  def index?
    allowed?("leave.read")
  end

  def show?
    allowed?("leave.read") && same_company?
  end

  def create?
    allowed?("leave.request")
  end

  def submit?
    create? && same_company?
  end

  def approve?
    allowed?("leave.approve") && same_company?
  end

  def reject?
    allowed?("leave.approve") && same_company?
  end

  def update?
    allowed?("leave.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("leave.read")

      company_scope
    end
  end
end
