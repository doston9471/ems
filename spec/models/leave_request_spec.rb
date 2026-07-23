# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeaveRequest, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:start_on) }
  it { is_expected.to validate_presence_of(:end_on) }
  it { is_expected.to validate_presence_of(:days) }

  it "rejects end_on before start_on" do
    request = build(:leave_request, start_on: Date.current + 5, end_on: Date.current + 2, days: 1)
    expect(request).not_to be_valid
    expect(request.errors[:end_on]).to be_present
  end
end
