# frozen_string_literal: true

FactoryBot.define do
  factory :employee do
    company
    department { association :department, company: company }
    office { association :office, company: company }
    sequence(:employee_number) { |n| "E#{n.to_s.rjust(4, '0')}" }
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    sequence(:email) { |n| "employee#{n}@example.com" }
    employment_status { "active" }
    joining_date { Date.current - 30 }
    currency { "USD" }
    salary_cents { 80_000_00 }
  end
end
