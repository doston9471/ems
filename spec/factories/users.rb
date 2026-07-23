# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "Password1!" }
    first_name { "Test" }
    last_name { "User" }
    email_verified_at { Time.current }
  end
end
