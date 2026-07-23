# frozen_string_literal: true

FactoryBot.define do
  factory :okr do
    company
    employee { association :employee, company: company }
    sequence(:objective) { |n| "Objective #{n}" }
    quarter { ((Date.current.month - 1) / 3) + 1 }
    year { Date.current.year }
    status { "open" }
  end
end
