# frozen_string_literal: true

FactoryBot.define do
  factory :scim_token do
    company
    sequence(:name) { |n| "SCIM token #{n}" }
    token_digest { ScimToken.digest(SecureRandom.hex(16)) }
  end
end
