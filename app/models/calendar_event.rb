# frozen_string_literal: true

class CalendarEvent < ApplicationRecord
  include Tenantable

  PROVIDERS = %w[google outlook].freeze
  STATUSES = %w[pending synced failed].freeze

  belongs_to :eventable, polymorphic: true

  validates :provider, presence: true, inclusion: { in: PROVIDERS }
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc) }
end
