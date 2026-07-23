# frozen_string_literal: true

class LeaveRequest < ApplicationRecord
  include Tenantable
  include Auditable

  belongs_to :employee
  belongs_to :leave_type
  belongs_to :manager, class_name: "Employee", optional: true
  belongs_to :hr, class_name: "Employee", optional: true

  has_many :leave_approvals, dependent: :destroy

  enum :status, {
    draft: "draft",
    pending_manager: "pending_manager",
    pending_hr: "pending_hr",
    approved: "approved",
    rejected: "rejected",
    cancelled: "cancelled"
  }, validate: true

  validates :start_on, :end_on, :days, presence: true
  validates :days, numericality: { greater_than: 0 }
  validate :end_on_not_before_start_on
  validate :associations_same_company

  private

  def end_on_not_before_start_on
    return if start_on.blank? || end_on.blank? || end_on >= start_on

    errors.add(:end_on, "must be on or after start_on")
  end

  def associations_same_company
    {
      employee: employee,
      leave_type: leave_type,
      manager: manager,
      hr: hr
    }.each do |attr, record|
      next if record.blank? || record.company_id == company_id

      errors.add(attr, "must belong to the same company")
    end
  end
end
