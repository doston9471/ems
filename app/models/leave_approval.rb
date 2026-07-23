# frozen_string_literal: true

class LeaveApproval < ApplicationRecord
  belongs_to :leave_request
  belongs_to :approver, class_name: "User"

  enum :step, { manager: "manager", hr: "hr" }, validate: true
  enum :decision, { approved: "approved", rejected: "rejected" }, validate: true

  validates :decided_at, presence: true
end
