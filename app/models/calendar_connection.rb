# frozen_string_literal: true

class CalendarConnection < ApplicationRecord
  include Tenantable

  PROVIDERS = %w[google outlook].freeze

  validates :provider, presence: true, inclusion: { in: PROVIDERS }, uniqueness: { scope: :company_id }

  scope :enabled, -> { where(enabled: true) }
  scope :for_provider, ->(provider) { where(provider: provider.to_s) }

  def credentials_present?
    access_token.present? && calendar_id.present?
  end
end
