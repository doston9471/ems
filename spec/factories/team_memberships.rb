# frozen_string_literal: true

FactoryBot.define do
  factory :team_membership do
    team
    employee { association :employee, company: team.company }
  end
end
