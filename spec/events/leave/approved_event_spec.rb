# frozen_string_literal: true

require "rails_helper"

RSpec.describe Leave::ApprovedEvent do
  subject(:event) do
    described_class.new(
      leave_request_id: 11,
      company_id: 22,
      employee_id: 33
    )
  end

  it "exposes leave_request_id, company_id, and employee_id accessors" do
    expect(event.leave_request_id).to eq(11)
    expect(event.company_id).to eq(22)
    expect(event.employee_id).to eq(33)
  end
end
