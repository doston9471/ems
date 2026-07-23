# frozen_string_literal: true

FactoryBot.define do
  factory :asset_assignment do
    company_asset { association :company_asset }
    employee { association :employee, company: company_asset.company }
    assigned_on { Date.current }
  end
end
