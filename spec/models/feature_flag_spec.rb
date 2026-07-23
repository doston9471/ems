# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeatureFlag do
  it "resolves global and company-scoped flags" do
    global_key = "spec_global_#{SecureRandom.hex(4)}"
    company_key = "spec_company_#{SecureRandom.hex(4)}"
    FeatureFlag.create!(key: global_key, enabled: true, company: nil)
    company = create(:company)
    FeatureFlag.create!(key: company_key, enabled: true, company: company)

    expect(described_class.enabled?(global_key)).to be(true)
    expect(described_class.enabled?(company_key, company: company)).to be(true)
    expect(described_class.enabled?("missing_#{SecureRandom.hex(4)}", company: company)).to be(false)
  end
end
