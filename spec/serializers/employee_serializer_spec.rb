# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeSerializer do
  let(:company) { create(:company) }
  let(:employee) do
    ActsAsTenant.with_tenant(company) do
      create(:employee, company: company, first_name: "Ada", last_name: "Lovelace",
                        email: "ada@example.com", job_title: "Engineer")
    end
  end

  it "serializes employee attributes including full_name" do
    hash = described_class.new(employee).serializable_hash
    attributes = hash[:data][:attributes]

    expect(attributes.keys).to contain_exactly(
      :employee_number, :first_name, :last_name, :email, :job_title,
      :employment_status, :department_id, :office_id, :manager_id, :joining_date, :full_name
    )
    expect(attributes[:first_name]).to eq("Ada")
    expect(attributes[:full_name]).to eq("Ada Lovelace")
    expect(hash[:data][:type]).to eq(:employee)
  end
end
