# frozen_string_literal: true

require "rails_helper"

RSpec.describe "My::NotificationPreferences", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user) }
  let!(:employee) { create(:employee, company: company, user: user) }

  around do |example|
    ActsAsTenant.with_tenant(company) { example.run }
  end

  before do
    role = create(:role, :with_permissions, permission_keys: %w[company.read])
    create(:membership, company: company, user: user, role: role)
    sign_in(user)
  end

  it "updates channel preferences" do
    get edit_my_notification_preferences_path
    expect(response).to have_http_status(:ok)

    patch my_notification_preferences_path, params: {
      preferences: { email: "1", slack: "0", telegram: "1", in_app: "1" }
    }

    expect(response).to redirect_to(edit_my_notification_preferences_path)
    user.reload
    expect(user.notification_channel_enabled?("email")).to be(true)
    expect(user.notification_channel_enabled?("slack")).to be(false)
  end
end
