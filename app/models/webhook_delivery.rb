# frozen_string_literal: true

class WebhookDelivery < ApplicationRecord
  belongs_to :webhook

  STATUSES = %w[pending delivered failed].freeze

  validates :event_key, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
end
