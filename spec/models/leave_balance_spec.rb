# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeaveBalance, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:year) }

  it "computes remaining days" do
    balance = create(:leave_balance, company: company, entitled: 20, used: 5)
    expect(balance.remaining).to eq(15)
  end
end
