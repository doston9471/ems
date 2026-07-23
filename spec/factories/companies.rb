# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    sequence(:slug) { |n| "company-#{n}" }
    timezone { "UTC" }
    locale { "en" }
    currency { "USD" }
    status { "active" }
    settings { { "work_start_time" => "09:00" } }
  end
end
