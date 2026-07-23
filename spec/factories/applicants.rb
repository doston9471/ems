# frozen_string_literal: true

FactoryBot.define do
  factory :applicant do
    company
    sequence(:first_name) { |n| "Applicant#{n}" }
    sequence(:last_name) { |n| "Candidate#{n}" }
    sequence(:email) { |n| "applicant#{n}@example.com" }
    phone { "+15555550100" }
    stage { "applied" }
    job_title { "Software Engineer" }
  end
end
