# frozen_string_literal: true

FactoryBot.define do
  factory :goal do
    company
    employee { association :employee, company: company }
    sequence(:title) { |n| "Goal #{n}" }
    status { "open" }
    progress_percent { 0 }
  end
end
