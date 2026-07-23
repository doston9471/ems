# frozen_string_literal: true

FactoryBot.define do
  factory :key_result do
    okr
    sequence(:title) { |n| "Key result #{n}" }
    target_value { 100 }
    current_value { 0 }
    unit { "%" }
  end
end
