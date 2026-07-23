# frozen_string_literal: true

require "rails_helper"

RSpec.describe Team, type: :model do
  let(:company) { create(:company) }

  around { |ex| ActsAsTenant.with_tenant(company) { ex.run } }

  it { is_expected.to validate_presence_of(:name) }

  it "belongs to optional department" do
    team = create(:team, company: company)
    expect(team.department.company).to eq(company)
  end
end
