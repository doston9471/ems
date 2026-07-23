# frozen_string_literal: true

class OrgChartPolicy < ApplicationPolicy
  def show?
    allowed?("employees.read")
  end
end
