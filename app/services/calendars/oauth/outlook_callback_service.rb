# frozen_string_literal: true

module Calendars
  module Oauth
    class OutlookCallbackService < ApplicationService
      TOKEN_URL = "https://login.microsoftonline.com/%{tenant}/oauth2/v2.0/token"

      def initialize(company:, code:, redirect_uri:)
        @company = company
        @code = code
        @redirect_uri = redirect_uri
      end

      def call
        client_id = ENV["OUTLOOK_CALENDAR_CLIENT_ID"].presence || ENV["MICROSOFT_CLIENT_ID"].presence
        client_secret = ENV["OUTLOOK_CALENDAR_CLIENT_SECRET"].presence || ENV["MICROSOFT_CLIENT_SECRET"].presence
        return failure("Outlook Calendar OAuth client is not configured") if client_id.blank? || client_secret.blank?
        return failure("Missing authorization code") if @code.blank?

        tokens = exchange_code(client_id: client_id, client_secret: client_secret)
        return failure(tokens[:error]) unless tokens[:success]

        connection = @company.calendar_connections.find_or_initialize_by(provider: "outlook")
        connection.assign_attributes(
          access_token: tokens[:access_token],
          refresh_token: tokens[:refresh_token].presence || connection.refresh_token,
          calendar_id: connection.calendar_id.presence || "primary",
          expires_at: tokens[:expires_at],
          enabled: true,
          metadata: (connection.metadata || {}).merge(
            "connected_via" => "oauth",
            "scope" => tokens[:scope],
            "token_type" => tokens[:token_type]
          )
        )
        connection.save!
        success(connection)
      rescue ActiveRecord::RecordInvalid => e
        failure(e.record.errors.full_messages)
      end

      private

      def exchange_code(client_id:, client_secret:)
        tenant = ENV.fetch("OUTLOOK_CALENDAR_TENANT", "common")
        uri = URI.parse(format(ENV.fetch("OUTLOOK_OAUTH_TOKEN_URL", TOKEN_URL), tenant: tenant))
        response = Net::HTTP.post_form(uri, {
          code: @code,
          client_id: client_id,
          client_secret: client_secret,
          redirect_uri: @redirect_uri,
          grant_type: "authorization_code",
          scope: OutlookAuthorizeService::SCOPE
        })
        body = JSON.parse(response.body) rescue {}
        unless response.is_a?(Net::HTTPSuccess)
          return { success: false, error: body["error_description"] || body["error"] || "Outlook token exchange failed" }
        end

        {
          success: true,
          access_token: body["access_token"],
          refresh_token: body["refresh_token"],
          expires_at: body["expires_in"].present? ? Time.current + body["expires_in"].to_i.seconds : nil,
          scope: body["scope"],
          token_type: body["token_type"]
        }
      rescue StandardError => e
        { success: false, error: e.message }
      end
    end
  end
end
