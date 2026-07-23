# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewCycle, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:period_start) }
  it { is_expected.to validate_presence_of(:period_end) }

  it "rejects period_end before period_start" do
    cycle = build(:review_cycle, company: company, period_start: Date.current, period_end: Date.yesterday)
    expect(cycle).not_to be_valid
  end
end
