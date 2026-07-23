# frozen_string_literal: true

FactoryBot.define do
  factory :attendance_event do
    company
    attendance_day { association :attendance_day, company: company }
    employee { attendance_day.employee }
    kind { "clock_in" }
    source { "web" }
    occurred_at { Time.current }
  end
end
