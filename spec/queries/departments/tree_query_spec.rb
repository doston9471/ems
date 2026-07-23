# frozen_string_literal: true

require "rails_helper"

RSpec.describe Departments::TreeQuery do
  let(:company) { create(:company) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  it "builds a parent → children department tree" do
    parent = create(:department, company: company, name: "Engineering")
    child = create(:department, company: company, name: "Platform", parent: parent)
    create(:department, company: company, name: "HR")

    roots = described_class.new(scope: Department.where(company: company)).call

    expect(roots.map { |node| node.department.name }).to include("Engineering", "HR")
    engineering = roots.find { |node| node.department.id == parent.id }
    expect(engineering.children.map { |node| node.department.id }).to eq([ child.id ])
  end
end
