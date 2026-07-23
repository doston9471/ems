# frozen_string_literal: true

class CalendarEventPolicy < ApplicationPolicy
  def index?
    allowed?("calendars.read") || allowed?("calendars.manage")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("calendars.read") || membership&.allows?("calendars.manage")

      company_scope
    end
  end
end
