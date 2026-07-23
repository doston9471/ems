# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def show?
    allowed?("company.read") || allowed?("employees.read")
  end
end
