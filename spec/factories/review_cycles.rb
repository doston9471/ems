# frozen_string_literal: true

FactoryBot.define do
  factory :review_cycle do
    company
    sequence(:name) { |n| "Cycle #{n}" }
    period_start { Date.current.beginning_of_quarter }
    period_end { Date.current.end_of_quarter }
    kind { "quarterly" }
    status { "open" }
  end
end
