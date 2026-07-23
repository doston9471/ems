# frozen_string_literal: true

FactoryBot.define do
  factory :payroll_run do
    company
    period_start { Date.current.beginning_of_month }
    period_end { Date.current.end_of_month }
    status { "draft" }
  end
end
