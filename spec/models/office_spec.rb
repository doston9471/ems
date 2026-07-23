# frozen_string_literal: true

require "rails_helper"

RSpec.describe Office, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:name) }

  it "scopes code uniqueness per company" do
    create(:office, company: company, code: "HQ")
    duplicate = build(:office, company: company, code: "HQ")
    expect(duplicate).not_to be_valid
  end
end
