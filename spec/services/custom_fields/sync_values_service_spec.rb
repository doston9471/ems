# frozen_string_literal: true

require "rails_helper"

RSpec.describe CustomFields::SyncValuesService do
  let(:company) { create(:company) }
  let(:employee) { create(:employee, company: company) }
  let!(:definition) do
    create(:custom_field_definition, company: company, key: "cost_center", label: "Cost center")
  end

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "creates and updates values for the record" do
    result = described_class.call(record: employee, values: { definition.id.to_s => "CC-100" })

    expect(result).to be_success
    value = employee.custom_field_values.find_by!(custom_field_definition: definition)
    expect(value.value).to eq("CC-100")

    described_class.call(record: employee, values: { definition.id.to_s => "CC-200" })
    expect(value.reload.value).to eq("CC-200")
  end
end
