# frozen_string_literal: true

require "rails_helper"

RSpec.describe CompanyAsset, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:name) }

  it "defines asset_type and status enums" do
    asset = create(:company_asset, company: company, asset_type: "laptop", status: "purchased")
    expect(asset).to be_laptop
    expect(asset).to be_purchased
  end
end
