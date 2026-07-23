# frozen_string_literal: true

class NotificationDelivery < ApplicationRecord
  include Tenantable

  CHANNELS = %w[email slack teams sms telegram in_app].freeze
  STATUSES = %w[pending sent failed skipped].freeze

  belongs_to :user, optional: true
  belongs_to :employee, optional: true

  validates :channel, inclusion: { in: CHANNELS }
  validates :event_key, :status, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :in_app, -> { where(channel: "in_app") }
  scope :unread, -> { where(read_at: nil) }
  scope :for_user, ->(user) { where(user_id: user.id) }

  def unread?
    read_at.nil?
  end

  def mark_read!
    update!(read_at: Time.current) if unread?
  end
end
