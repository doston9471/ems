# frozen_string_literal: true

FactoryBot.define do
  factory :leave_balance do
    company
    employee { association :employee, company: company }
    leave_type { association :leave_type, company: company }
    year { Date.current.year }
    entitled { 20 }
    used { 2 }
  end
end
