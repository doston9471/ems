# frozen_string_literal: true

class AssetAssignment < ApplicationRecord
  belongs_to :company_asset
  belongs_to :employee

  validates :assigned_on, presence: true
  validate :returned_on_not_before_assigned_on
  validate :employee_same_company_as_asset

  scope :active, -> { where(returned_on: nil) }

  private

  def returned_on_not_before_assigned_on
    return if returned_on.blank? || assigned_on.blank? || returned_on >= assigned_on

    errors.add(:returned_on, "must be on or after assigned_on")
  end

  def employee_same_company_as_asset
    return if employee.blank? || company_asset.blank?
    return if employee.company_id == company_asset.company_id

    errors.add(:employee, "must belong to the same company as the asset")
  end
end
