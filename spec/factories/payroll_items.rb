# frozen_string_literal: true

FactoryBot.define do
  factory :payroll_item do
    payroll_run
    employee { association :employee, company: payroll_run.company }
    salary_cents { 500_000 }
    bonus_cents { 0 }
    commission_cents { 0 }
    tax_cents { 50_000 }
    insurance_cents { 10_000 }
    net_cents { 440_000 }
    currency { "USD" }
  end
end
