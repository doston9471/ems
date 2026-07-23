# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  def show?
    allowed?("company.read") && current_tenant?
  end

  def update?
    allowed?("company.update") && current_tenant?
  end

  private

  def current_tenant?
    membership.present? && record.is_a?(Company) && record.id == membership.company_id
  end
end
