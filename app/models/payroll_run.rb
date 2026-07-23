# frozen_string_literal: true

class PayrollRun < ApplicationRecord
  include Tenantable
  include Auditable

  has_many :payroll_items, dependent: :destroy

  enum :status, {
    draft: "draft",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }, validate: true

  validates :period_start, :period_end, presence: true
  validate :period_end_after_start

  private

  def period_end_after_start
    return if period_start.blank? || period_end.blank?
    return if period_end >= period_start

    errors.add(:period_end, "must be on or after period start")
  end
end
