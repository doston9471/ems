# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeaveType, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:name) }

  it "scopes key uniqueness per company" do
    create(:leave_type, company: company, key: "pto")
    duplicate = build(:leave_type, company: company, key: "pto")
    expect(duplicate).not_to be_valid
  end
end
