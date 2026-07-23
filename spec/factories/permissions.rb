# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    sequence(:key) { |n| "custom.perm#{n}" }
    sequence(:name) { |n| "Permission #{n}" }
    category { "custom" }
  end
end
