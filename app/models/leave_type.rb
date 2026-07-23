# frozen_string_literal: true

class LeaveType < ApplicationRecord
  include Tenantable
  include Auditable

  has_many :leave_balances, dependent: :restrict_with_exception
  has_many :leave_requests, dependent: :restrict_with_exception

  validates :key, :name, presence: true
  validates :key, uniqueness: { scope: :company_id }, format: { with: /\A[a-z][a-z0-9_]*\z/ }
end
