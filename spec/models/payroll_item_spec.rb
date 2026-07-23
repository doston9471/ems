# frozen_string_literal: true

require "rails_helper"

RSpec.describe PayrollItem, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:currency) }

  it "enforces unique employee per payroll run" do
    item = create(:payroll_item)
    duplicate = build(:payroll_item, payroll_run: item.payroll_run, employee: item.employee)
    expect(duplicate).not_to be_valid
  end
end
