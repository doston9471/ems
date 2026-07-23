# frozen_string_literal: true

require "rails_helper"

RSpec.describe Performance::CloseCycleService do
  let(:company) { create(:company) }
  let(:cycle) { create(:review_cycle, company: company, status: :open) }
  let(:employee) { create(:employee, company: company) }
  let(:reviewer) { create(:employee, company: company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "completes submitted reviews and closes the cycle" do
    submitted = create(:performance_review, company: company, review_cycle: cycle, employee: employee, reviewer: reviewer, status: :submitted)
    create(:performance_review, company: company, review_cycle: cycle, employee: employee, reviewer: employee, review_type: :self, status: :completed)

    result = described_class.call(review_cycle: cycle)

    expect(result).to be_success
    expect(cycle.reload).to be_closed
    expect(submitted.reload).to be_completed
  end

  it "refuses to close when pending reviews remain" do
    create(:performance_review, company: company, review_cycle: cycle, employee: employee, reviewer: reviewer, status: :pending)

    result = described_class.call(review_cycle: cycle)

    expect(result).not_to be_success
    expect(result.errors.join).to include("pending")
    expect(cycle.reload).to be_open
  end

  it "force-closes pending reviews" do
    pending = create(:performance_review, company: company, review_cycle: cycle, employee: employee, reviewer: reviewer, status: :pending)

    result = described_class.call(review_cycle: cycle, force: true)

    expect(result).to be_success
    expect(cycle.reload).to be_closed
    expect(pending.reload).to be_completed
  end

  it "blocks assign after close" do
    described_class.call(review_cycle: cycle)
    result = Performance::AssignReviewsService.call(
      review_cycle: cycle.reload,
      employee_ids: [ employee.id ],
      include_self: true,
      include_manager: false
    )

    expect(result).not_to be_success
    expect(result.errors.join).to include("open")
  end
end
