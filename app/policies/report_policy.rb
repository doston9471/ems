# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  def index?
    allowed?("reports.read") || allowed?("reports.export")
  end

  def export?
    allowed?("reports.export")
  end
end
