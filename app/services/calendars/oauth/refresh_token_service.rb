# frozen_string_literal: true

module Calendars
  module Oauth
    class RefreshTokenService < ApplicationService
      GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
      OUTLOOK_TOKEN_URL = "https://login.microsoftonline.com/%{tenant}/oauth2/v2.0/token"

      def initialize(connection:)
        @connection = connection
      end

      def call
        return success(@connection) if @connection.expires_at.blank? || @connection.expires_at > 2.minutes.from_now
        return failure("No refresh_token for #{@connection.provider}") if @connection.refresh_token.blank?

        result = case @connection.provider
        when "google" then refresh_google
        when "outlook" then refresh_outlook
        else
                   { success: false, error: "Unsupported provider" }
        end
        return failure(result[:error]) unless result[:success]

        @connection.update!(
          access_token: result[:access_token],
          refresh_token: result[:refresh_token].presence || @connection.refresh_token,
          expires_at: result[:expires_at]
        )
        success(@connection)
      rescue ActiveRecord::RecordInvalid => e
        failure(e.record.errors.full_messages)
      end

      private

      def refresh_google
        client_id = ENV["GOOGLE_CALENDAR_CLIENT_ID"].presence || ENV["GOOGLE_CLIENT_ID"]
        client_secret = ENV["GOOGLE_CALENDAR_CLIENT_SECRET"].presence || ENV["GOOGLE_CLIENT_SECRET"]
        return { success: false, error: "Google OAuth client not configured" } if client_id.blank? || client_secret.blank?

        post_refresh(
          ENV.fetch("GOOGLE_OAUTH_TOKEN_URL", GOOGLE_TOKEN_URL),
          client_id: client_id,
          client_secret: client_secret
        )
      end

      def refresh_outlook
        client_id = ENV["OUTLOOK_CALENDAR_CLIENT_ID"].presence || ENV["MICROSOFT_CLIENT_ID"]
        client_secret = ENV["OUTLOOK_CALENDAR_CLIENT_SECRET"].presence || ENV["MICROSOFT_CLIENT_SECRET"]
        return { success: false, error: "Outlook OAuth client not configured" } if client_id.blank? || client_secret.blank?

        tenant = ENV.fetch("OUTLOOK_CALENDAR_TENANT", "common")
        url = format(ENV.fetch("OUTLOOK_OAUTH_TOKEN_URL", OUTLOOK_TOKEN_URL), tenant: tenant)
        post_refresh(url, client_id: client_id, client_secret: client_secret, scope: OutlookAuthorizeService::SCOPE)
      end

      def post_refresh(url, client_id:, client_secret:, scope: nil)
        form = {
          client_id: client_id,
          client_secret: client_secret,
          refresh_token: @connection.refresh_token,
          grant_type: "refresh_token"
        }
        form[:scope] = scope if scope.present?

        response = Net::HTTP.post_form(URI.parse(url), form)
        body = JSON.parse(response.body) rescue {}
        unless response.is_a?(Net::HTTPSuccess)
          return { success: false, error: body["error_description"] || body["error"] || "Token refresh failed" }
        end

        {
          success: true,
          access_token: body["access_token"],
          refresh_token: body["refresh_token"],
          expires_at: body["expires_in"].present? ? Time.current + body["expires_in"].to_i.seconds : nil
        }
      rescue StandardError => e
        { success: false, error: e.message }
      end
    end
  end
end
