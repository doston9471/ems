# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_identity do
    user
    provider { "google_oauth2" }
    sequence(:uid) { |n| "oauth-uid-#{n}" }
    email { user.email_address }
    raw_metadata { { "provider" => provider, "uid" => uid } }
  end
end
