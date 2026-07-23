# frozen_string_literal: true

class AuditLog < ApplicationRecord
  self.record_timestamps = false

  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  validates :auditable_type, :auditable_id, :action, :created_at, presence: true
end
