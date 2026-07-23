# frozen_string_literal: true

require "rails_helper"

RSpec.describe Kpi, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:period) }

  it "belongs to employee within company" do
    kpi = create(:kpi, company: company)
    expect(kpi.employee.company).to eq(company)
  end
end
