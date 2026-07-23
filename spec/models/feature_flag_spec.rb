# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeatureFlag do
  it "resolves global and company-scoped flags" do
    FeatureFlag.create!(key: "dark_mode", enabled: true, company: nil)
    company = create(:company)
    FeatureFlag.create!(key: "org_chart", enabled: true, company: company)

    expect(described_class.enabled?("dark_mode")).to be(true)
    expect(described_class.enabled?("org_chart", company: company)).to be(true)
    expect(described_class.enabled?("missing", company: company)).to be(false)
  end
end
