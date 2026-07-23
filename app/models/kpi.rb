# frozen_string_literal: true

class Kpi < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :employee

  validates :name, :period, presence: true
  validates :target_value, :current_value, numericality: true
  validate :employee_same_company

  private

  def employee_same_company
    return if employee.blank? || employee.company_id == company_id

    errors.add(:employee, "must belong to the same company")
  end
end
