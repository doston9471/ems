# frozen_string_literal: true

class Webhook < ApplicationRecord
  include Tenantable

  has_many :webhook_deliveries, dependent: :destroy

  validates :url, :secret, presence: true
  validates :url, format: { with: /\Ahttps?:\/\/.+\z/i, message: "must be an HTTP(S) URL" }

  scope :active, -> { where(active: true) }

  def listens_to?(event_key)
    keys = Array(event_keys).map(&:to_s)
    keys.include?("*") || keys.include?(event_key.to_s)
  end
end
