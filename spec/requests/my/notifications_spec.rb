# frozen_string_literal: true

require "rails_helper"

RSpec.describe "My::Notifications", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let!(:employee) { create(:employee, company: company, user: user) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  before do
    role = create(:role, :with_permissions, permission_keys: %w[company.read notifications.read])
    create(:membership, company: company, user: user, role: role)
    sign_in(user)
  end

  it "lists inbox items and marks one as read" do
    get my_notifications_path
    expect(response).to have_http_status(:ok)

    note = NotificationDelivery.create!(
      company: company,
      user: user,
      employee: employee,
      channel: "in_app",
      event_key: "leave.approved",
      status: "sent",
      payload: {}
    )

    post mark_read_my_notification_path(note)
    expect(note.reload.read_at).to be_present
  end
end
