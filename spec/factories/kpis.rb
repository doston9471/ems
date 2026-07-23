# frozen_string_literal: true

FactoryBot.define do
  factory :kpi do
    company
    employee { association :employee, company: company }
    sequence(:name) { |n| "KPI #{n}" }
    period { "2026-Q1" }
    target_value { 100 }
    current_value { 40 }
    unit { "%" }
  end
end
