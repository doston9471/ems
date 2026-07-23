# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgChartQuery do
  let(:company) { create(:company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "builds a manager → reports tree" do
    manager = create(:employee, company: company, first_name: "Morgan", last_name: "Manager")
    report = create(:employee, company: company, first_name: "Eddie", last_name: "Employee", manager: manager)

    roots = described_class.new(company: company).call

    expect(roots.map { |node| node.employee.id }).to include(manager.id)
    manager_node = roots.find { |node| node.employee.id == manager.id }
    expect(manager_node.children.map { |node| node.employee.id }).to eq([ report.id ])
  end
end
