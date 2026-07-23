# frozen_string_literal: true

class Membership < ApplicationRecord
  include Auditable

  belongs_to :company
  belongs_to :user
  belongs_to :role

  enum :status, { active: "active", invited: "invited", suspended: "suspended" }, validate: true

  validates :user_id, uniqueness: { scope: :company_id }
  validate :role_belongs_to_company_or_system

  def allows?(permission_key)
    return true if user&.super_admin?

    permission_keys.include?(permission_key.to_s)
  end

  def permission_keys
    @permission_keys ||= role.permissions.pluck(:key)
  end

  private

  def role_belongs_to_company_or_system
    return if role.blank?
    return if role.company_id.nil? || role.company_id == company_id

    errors.add(:role, "must belong to the same company or be a system role")
  end
end
