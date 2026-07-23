# frozen_string_literal: true

require "rails_helper"

RSpec.describe Performance::SubmitReviewService do
  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company) }
  let(:reviewer) { create(:employee, company: company) }
  let(:review_cycle) { create(:review_cycle, company: company, status: "open") }
  let(:performance_review) do
    create(
      :performance_review,
      company: company,
      review_cycle: review_cycle,
      employee: employee,
      reviewer: reviewer,
      status: "pending"
    )
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "submits a pending review with rating and feedback" do
    result = described_class.call(
      performance_review: performance_review,
      attributes: { overall_rating: 4.5 },
      feedback_attributes: { body: "Strong quarter", rating: 4.5 }
    )

    expect(result).to be_success
    expect(result.value).to be_submitted
    expect(result.value.overall_rating).to eq(BigDecimal("4.5"))
    expect(result.value.submitted_at).to be_present
    expect(result.value.review_feedbacks.count).to eq(1)
    expect(result.value.review_feedbacks.first.body).to eq("Strong quarter")
  end

  it "rejects non-pending reviews" do
    performance_review.update!(status: "submitted", submitted_at: Time.current)

    result = described_class.call(performance_review: performance_review)

    expect(result).to be_failure
    expect(result.errors.join).to match(/pending/i)
  end

  it "rejects when the cycle is not open" do
    review_cycle.update!(status: "closed")

    result = described_class.call(performance_review: performance_review)

    expect(result).to be_failure
    expect(result.errors.join).to match(/not open/i)
  end
end
