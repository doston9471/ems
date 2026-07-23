# frozen_string_literal: true

class EmployeeDocument < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :employee
  has_many :document_versions, dependent: :destroy

  enum :doc_type, {
    passport: "passport",
    contract: "contract",
    visa: "visa",
    certificate: "certificate",
    nda: "nda",
    insurance: "insurance",
    other: "other"
  }, validate: true

  enum :status, {
    active: "active",
    archived: "archived",
    expired: "expired"
  }, validate: true

  validates :title, presence: true
  validate :employee_same_company

  def latest_version
    document_versions.order(version_number: :desc).first
  end

  private

  def employee_same_company
    return if employee.blank? || employee.company_id == company_id

    errors.add(:employee, "must belong to the same company")
  end
end
