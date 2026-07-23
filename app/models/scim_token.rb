# frozen_string_literal: true

class ScimToken < ApplicationRecord
  include Tenantable

  validates :token_digest, presence: true, uniqueness: true

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def self.find_by_raw_token(raw_token)
    find_by(token_digest: digest(raw_token))
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end
end
