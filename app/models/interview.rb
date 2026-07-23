# frozen_string_literal: true

class Interview < ApplicationRecord
  include Auditable

  belongs_to :applicant
  belongs_to :interviewer, class_name: "Employee"

  enum :mode, {
    video: "video",
    phone: "phone",
    in_person: "in_person"
  }, validate: true

  enum :status, {
    scheduled: "scheduled",
    completed: "completed",
    cancelled: "cancelled",
    no_show: "no_show"
  }, validate: true

  validates :scheduled_at, presence: true
  validate :interviewer_same_company

  private

  def interviewer_same_company
    return if applicant.blank? || interviewer.blank?
    return if interviewer.company_id == applicant.company_id

    errors.add(:interviewer, "must belong to the same company as the applicant")
  end
end
