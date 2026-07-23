# frozen_string_literal: true

FactoryBot.define do
  factory :interview do
    applicant
    interviewer { association :employee, company: applicant.company }
    scheduled_at { 2.days.from_now }
    mode { "video" }
    status { "scheduled" }
  end
end
