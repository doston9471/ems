# frozen_string_literal: true

module Calendars
  module Oauth
    class GoogleAuthorizeService < ApplicationService
      AUTHORIZE_URL = "https://accounts.google.com/o/oauth2/v2/auth"
      SCOPE = "https://www.googleapis.com/auth/calendar.events https://www.googleapis.com/auth/userinfo.email"

      def initialize(redirect_uri:, state:)
        @redirect_uri = redirect_uri
        @state = state
      end

      def call
        client_id = ENV["GOOGLE_CALENDAR_CLIENT_ID"].presence || ENV["GOOGLE_CLIENT_ID"].presence
        return failure("GOOGLE_CALENDAR_CLIENT_ID (or GOOGLE_CLIENT_ID) is not configured") if client_id.blank?
        return failure("redirect_uri is required") if @redirect_uri.blank?

        query = {
          client_id: client_id,
          redirect_uri: @redirect_uri,
          response_type: "code",
          scope: SCOPE,
          access_type: "offline",
          prompt: "consent",
          state: @state
        }
        success("#{AUTHORIZE_URL}?#{query.to_query}")
      end
    end
  end
end
