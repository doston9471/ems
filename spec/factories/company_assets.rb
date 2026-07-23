# frozen_string_literal: true

FactoryBot.define do
  factory :company_asset do
    company
    sequence(:name) { |n| "Asset #{n}" }
    asset_type { "laptop" }
    sequence(:serial_number) { |n| "SN-#{n}" }
    status { "purchased" }
    purchased_on { Date.current - 30 }
  end
end
