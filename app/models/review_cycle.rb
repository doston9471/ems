# frozen_string_literal: true

class ReviewCycle < ApplicationRecord
  include Tenantable
  include Auditable

  has_many :performance_reviews, dependent: :restrict_with_exception

  enum :kind, {
    quarterly: "quarterly",
    annual: "annual",
    ad_hoc: "ad_hoc"
  }, validate: true

  enum :status, {
    draft: "draft",
    open: "open",
    closed: "closed"
  }, validate: true

  validates :name, :period_start, :period_end, presence: true
  validate :period_end_not_before_start

  private

  def period_end_not_before_start
    return if period_start.blank? || period_end.blank? || period_end >= period_start

    errors.add(:period_end, "must be on or after period_start")
  end
end
