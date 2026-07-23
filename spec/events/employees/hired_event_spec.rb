# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employees::HiredEvent do
  subject(:event) do
    described_class.new(
      employee_id: 10,
      company_id: 20,
      applicant_id: 30
    )
  end

  it "exposes employee_id, company_id, and applicant_id accessors" do
    expect(event.employee_id).to eq(10)
    expect(event.company_id).to eq(20)
    expect(event.applicant_id).to eq(30)
  end
end
