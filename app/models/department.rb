# frozen_string_literal: true

class Department < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :parent, class_name: "Department", optional: true

  has_many :children, class_name: "Department", foreign_key: :parent_id, inverse_of: :parent, dependent: :nullify
  has_many :employees, dependent: :nullify
  has_many :teams, dependent: :nullify
  has_many :applicants, dependent: :nullify

  validates :name, presence: true
  validates :code, uniqueness: { scope: :company_id }, allow_nil: true
  validate :parent_same_company

  private

  def parent_same_company
    return if parent.blank? || parent.company_id == company_id

    errors.add(:parent, "must belong to the same company")
  end
end
