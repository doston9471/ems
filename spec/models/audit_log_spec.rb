# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuditLog, type: :model do
  it { is_expected.to validate_presence_of(:auditable_type) }
  it { is_expected.to validate_presence_of(:auditable_id) }
  it { is_expected.to validate_presence_of(:action) }
  it { is_expected.to validate_presence_of(:created_at) }

  it "records a polymorphic auditable" do
    company = create(:company)
    log = ActsAsTenant.with_tenant(company) { create(:audit_log, company: company, action: "create") }
    expect(log.auditable).to be_a(Employee)
    expect(log.action).to eq("create")
  end
end
