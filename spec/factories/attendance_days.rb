# frozen_string_literal: true

FactoryBot.define do
  factory :attendance_day do
    company
    employee { association :employee, company: company }
    work_date { Date.current }
    status { "open" }
    worked_minutes { 0 }
    overtime_minutes { 0 }
    break_minutes { 0 }
  end
end
