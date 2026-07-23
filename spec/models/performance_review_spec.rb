# frozen_string_literal: true

require "rails_helper"

RSpec.describe PerformanceReview, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:review_type) }
  it { is_expected.to validate_presence_of(:status) }

  it "defines review_type and status enums" do
    review = create(:performance_review, company: company, review_type: "manager", status: "pending")
    expect(review).to be_review_type_manager
    expect(review).to be_pending
  end
end
