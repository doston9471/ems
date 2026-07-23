# frozen_string_literal: true

require "rails_helper"

RSpec.describe Calendars::Oauth::GoogleAuthorizeService do
  around do |example|
    previous = ENV.to_hash.slice("GOOGLE_CALENDAR_CLIENT_ID", "GOOGLE_CLIENT_ID")
    example.run
  ensure
    previous.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
    (%w[GOOGLE_CALENDAR_CLIENT_ID GOOGLE_CLIENT_ID] - previous.keys).each { |k| ENV.delete(k) }
  end

  it "builds a Google OAuth authorize URL when client id is present" do
    ENV["GOOGLE_CALENDAR_CLIENT_ID"] = "cal-client"
    ENV.delete("GOOGLE_CLIENT_ID")

    result = described_class.call(
      redirect_uri: "http://localhost:3000/calendar_oauth/google/callback",
      state: "state-1"
    )

    expect(result).to be_success
    params = Rack::Utils.parse_query(URI.parse(result.value).query)
    expect(params["client_id"]).to eq("cal-client")
    expect(params["access_type"]).to eq("offline")
    expect(params["scope"]).to include("calendar.events")
  end

  it "fails when client id is missing" do
    ENV.delete("GOOGLE_CALENDAR_CLIENT_ID")
    ENV.delete("GOOGLE_CLIENT_ID")

    result = described_class.call(redirect_uri: "http://localhost/cb", state: "x")
    expect(result).to be_failure
  end
end
