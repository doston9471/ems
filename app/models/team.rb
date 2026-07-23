# frozen_string_literal: true

class Team < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :department, optional: true
  belongs_to :lead_employee, class_name: "Employee", optional: true

  has_many :team_memberships, dependent: :destroy
  has_many :employees, through: :team_memberships

  validates :name, presence: true
  validate :department_same_company
  validate :lead_same_company

  private

  def department_same_company
    return if department.blank? || department.company_id == company_id

    errors.add(:department, "must belong to the same company")
  end

  def lead_same_company
    return if lead_employee.blank? || lead_employee.company_id == company_id

    errors.add(:lead_employee, "must belong to the same company")
  end
end
