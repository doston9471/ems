# frozen_string_literal: true

require "rails_helper"

RSpec.describe Performance::AssignReviewsService do
  let(:company) { create(:company) }
  let(:cycle) { create(:review_cycle, company: company, status: :open) }
  let(:manager) { create(:employee, company: company) }
  let(:employee) { create(:employee, company: company, manager: manager) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates self and manager reviews for selected employees" do
    result = described_class.call(
      review_cycle: cycle,
      employee_ids: [ employee.id ],
      include_self: true,
      include_manager: true
    )

    expect(result).to be_success
    expect(result.value[:reviews].size).to eq(2)
    expect(cycle.performance_reviews.pluck(:review_type)).to contain_exactly("self", "manager")
  end

  it "warns when an employee has no manager" do
    solo = create(:employee, company: company, manager: nil)

    result = described_class.call(
      review_cycle: cycle,
      employee_ids: [ solo.id ],
      include_self: false,
      include_manager: true
    )

    expect(result).to be_success
    expect(result.value[:reviews]).to be_empty
    expect(result.value[:warnings].join).to match(/no manager/i)
  end

  it "creates a peer review assignment" do
    peer = create(:employee, company: company)

    result = described_class.call(
      review_cycle: cycle,
      employee_ids: [],
      include_self: false,
      include_manager: false,
      peer_assignments: [ { employee_id: employee.id, reviewer_id: peer.id } ]
    )

    expect(result).to be_success
    review = result.value[:reviews].sole
    expect(review.review_type).to eq("peer_360")
    expect(review.reviewer).to eq(peer)
  end

  it "skips duplicates on re-assign" do
    described_class.call(review_cycle: cycle, employee_ids: [ employee.id ], include_self: true, include_manager: false)
    result = described_class.call(review_cycle: cycle, employee_ids: [ employee.id ], include_self: true, include_manager: false)

    expect(result).to be_success
    expect(result.value[:reviews]).to be_empty
    expect(cycle.performance_reviews.where(review_type: :self).count).to eq(1)
  end

  it "fails when the cycle is closed" do
    cycle.update!(status: :closed)

    result = described_class.call(review_cycle: cycle, employee_ids: [ employee.id ])

    expect(result).to be_failure
    expect(result.errors.join).to match(/open/i)
  end
end
