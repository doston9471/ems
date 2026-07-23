# frozen_string_literal: true

FactoryBot.define do
  factory :feature_flag do
    company { nil }
    sequence(:key) { |n| "flag_#{n}" }
    enabled { false }
    description { "Test flag" }
  end
end
