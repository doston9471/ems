# frozen_string_literal: true

module Calendars
  module Oauth
    class OutlookAuthorizeService < ApplicationService
      AUTHORIZE_URL = "https://login.microsoftonline.com/%{tenant}/oauth2/v2.0/authorize"
      SCOPE = "offline_access Calendars.ReadWrite User.Read"

      def initialize(redirect_uri:, state:)
        @redirect_uri = redirect_uri
        @state = state
      end

      def call
        client_id = ENV["OUTLOOK_CALENDAR_CLIENT_ID"].presence || ENV["MICROSOFT_CLIENT_ID"].presence
        return failure("OUTLOOK_CALENDAR_CLIENT_ID (or MICROSOFT_CLIENT_ID) is not configured") if client_id.blank?
        return failure("redirect_uri is required") if @redirect_uri.blank?

        tenant = ENV.fetch("OUTLOOK_CALENDAR_TENANT", "common")
        query = {
          client_id: client_id,
          redirect_uri: @redirect_uri,
          response_type: "code",
          scope: SCOPE,
          response_mode: "query",
          state: @state
        }
        success(format(AUTHORIZE_URL, tenant: tenant) + "?#{query.to_query}")
      end
    end
  end
end
