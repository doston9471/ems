# frozen_string_literal: true

require "rails_helper"

RSpec.describe Department, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:name) }

  it "scopes code uniqueness per company" do
    create(:department, company: company, code: "ENG")
    duplicate = build(:department, company: company, code: "ENG")
    expect(duplicate).not_to be_valid
  end
end
