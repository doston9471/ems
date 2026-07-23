# frozen_string_literal: true

FactoryBot.define do
  factory :webhook do
    company
    sequence(:url) { |n| "https://hooks.example.com/ems-#{n}" }
    secret { SecureRandom.hex(16) }
    event_keys { [ "*" ] }
    active { true }
  end
end
