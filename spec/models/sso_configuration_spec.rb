# frozen_string_literal: true

require "rails_helper"

RSpec.describe SsoConfiguration, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:provider) }
  it { is_expected.to validate_presence_of(:metadata) }

  it "scopes provider uniqueness per company" do
    create(:sso_configuration, company: company, provider: "saml")
    duplicate = build(:sso_configuration, company: company, provider: "saml")
    expect(duplicate).not_to be_valid
  end
end
