# frozen_string_literal: true

class CalendarConnectionPolicy < ApplicationPolicy
  def index?
    allowed?("calendars.read") || allowed?("calendars.manage")
  end

  def create?
    allowed?("calendars.manage")
  end

  def destroy?
    allowed?("calendars.manage") && same_company?
  end

  def update?
    allowed?("calendars.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("calendars.read") || membership&.allows?("calendars.manage")

      company_scope
    end
  end
end
