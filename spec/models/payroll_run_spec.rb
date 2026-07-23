# frozen_string_literal: true

require "rails_helper"

RSpec.describe PayrollRun, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:period_start) }
  it { is_expected.to validate_presence_of(:period_end) }

  it "rejects period_end before period_start" do
    run = build(:payroll_run, company: company, period_start: Date.current, period_end: Date.yesterday)
    expect(run).not_to be_valid
    expect(run.errors[:period_end]).to be_present
  end
end
