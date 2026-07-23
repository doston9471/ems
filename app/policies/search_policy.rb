# frozen_string_literal: true

class SearchPolicy < ApplicationPolicy
  def show?
    allowed?("employees.read") || allowed?("departments.read")
  end
end
