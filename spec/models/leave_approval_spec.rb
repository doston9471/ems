# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeaveApproval, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:decided_at) }

  it "defines step and decision enums" do
    approval = create(:leave_approval, step: "manager", decision: "approved")
    expect(approval).to be_manager
    expect(approval).to be_approved
  end
end
