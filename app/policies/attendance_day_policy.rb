# frozen_string_literal: true

class AttendanceDayPolicy < ApplicationPolicy
  def index?
    allowed?("attendance.read")
  end

  def show?
    allowed?("attendance.read") && same_company?
  end

  def create?
    allowed?("attendance.clock") || allowed?("attendance.manage")
  end

  def clock_in?
    create?
  end

  def clock_out?
    create?
  end

  def break_start?
    create?
  end

  def break_end?
    create?
  end

  def update?
    allowed?("attendance.manage") && same_company?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("attendance.read") || membership&.allows?("attendance.clock")

      company_scope
    end
  end
end
