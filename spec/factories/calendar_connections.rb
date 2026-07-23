# frozen_string_literal: true

FactoryBot.define do
  factory :calendar_connection do
    company
    provider { "google" }
    access_token { "test-access-token" }
    refresh_token { "test-refresh-token" }
    calendar_id { "primary" }
    metadata { { "stub" => true } }
    enabled { true }
    expires_at { 1.day.from_now }

    trait :outlook do
      provider { "outlook" }
    end

    trait :disabled do
      enabled { false }
    end
  end
end
