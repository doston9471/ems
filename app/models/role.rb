# frozen_string_literal: true

class Role < ApplicationRecord
  belongs_to :company, optional: true

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions
  has_many :memberships, dependent: :restrict_with_exception

  validates :key, :name, presence: true
  validates :key, uniqueness: { scope: :company_id }
  validates :key, format: { with: /\A[a-z][a-z0-9_]*\z/ }

  scope :system_roles, -> { where(system: true, company_id: nil) }
  scope :for_company, ->(company) { where(company_id: [ nil, company.id ]) }
end
