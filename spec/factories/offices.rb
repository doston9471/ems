# frozen_string_literal: true

FactoryBot.define do
  factory :office do
    company
    sequence(:name) { |n| "Office #{n}" }
    sequence(:code) { |n| "O#{n}" }
    active { true }
  end
end
