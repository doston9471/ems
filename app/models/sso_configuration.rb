# frozen_string_literal: true

class SsoConfiguration < ApplicationRecord
  include Tenantable

  PROVIDERS = %w[saml oidc].freeze

  validates :provider, presence: true, inclusion: { in: PROVIDERS }, uniqueness: { scope: :company_id }
  validates :metadata, presence: true
end
