# frozen_string_literal: true

require "rails_helper"

RSpec.describe Interview, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:scheduled_at) }

  it "defines mode and status enums" do
    interview = create(:interview, mode: "video", status: "scheduled")
    expect(interview).to be_video
    expect(interview).to be_scheduled
  end
end
