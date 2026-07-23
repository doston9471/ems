# frozen_string_literal: true

require "rails_helper"

RSpec.describe Leave::SubmitRequestService do
  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company) }
  let(:leave_type) { create(:leave_type, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "submits a draft request to pending_manager" do
    result = described_class.call(
      employee: employee,
      attributes: {
        leave_type: leave_type,
        start_on: Date.current + 5,
        end_on: Date.current + 7,
        reason: "Trip"
      }
    )

    expect(result).to be_success
    expect(result.value.status).to eq("pending_manager")
    expect(result.value.days).to eq(3)
  end
end
