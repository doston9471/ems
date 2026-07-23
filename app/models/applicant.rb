# frozen_string_literal: true

class Applicant < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :department, optional: true
  belongs_to :hired_employee, class_name: "Employee", optional: true
  has_many :interviews, dependent: :destroy

  enum :stage, {
    applied: "applied",
    interview: "interview",
    offer: "offer",
    rejected: "rejected",
    hired: "hired"
  }, validate: true

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :first_name, :last_name, :email, presence: true
  validate :department_same_company

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def department_same_company
    return if department.blank? || department.company_id == company_id

    errors.add(:department, "must belong to the same company")
  end
end
