# frozen_string_literal: true

FactoryBot.define do
  factory :leave_request do
    employee
    company { employee.company }
    leave_type { association :leave_type, company: employee.company }
    start_on { Date.current + 7 }
    end_on { Date.current + 9 }
    days { 3 }
    status { "draft" }
    reason { "Vacation" }
  end
end
