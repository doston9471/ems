# frozen_string_literal: true

require "rails_helper"

RSpec.describe DepartmentSerializer do
  let(:company) { create(:company) }
  let(:department) do
    ActsAsTenant.with_tenant(company) do
      create(:department, company: company, name: "Engineering", code: "ENG", active: true)
    end
  end

  it "serializes department attributes" do
    hash = described_class.new(department).serializable_hash
    attributes = hash[:data][:attributes]

    expect(attributes.keys).to contain_exactly(:name, :code, :active, :parent_id)
    expect(attributes[:name]).to eq("Engineering")
    expect(attributes[:code]).to eq("ENG")
    expect(attributes[:active]).to be(true)
    expect(hash[:data][:type]).to eq(:department)
  end
end
