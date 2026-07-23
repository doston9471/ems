# frozen_string_literal: true

module Calendars
  module Oauth
    class GoogleCallbackService < ApplicationService
      TOKEN_URL = "https://oauth2.googleapis.com/token"

      def initialize(company:, code:, redirect_uri:)
        @company = company
        @code = code
        @redirect_uri = redirect_uri
      end

      def call
        client_id = ENV["GOOGLE_CALENDAR_CLIENT_ID"].presence || ENV["GOOGLE_CLIENT_ID"].presence
        client_secret = ENV["GOOGLE_CALENDAR_CLIENT_SECRET"].presence || ENV["GOOGLE_CLIENT_SECRET"].presence
        return failure("Google Calendar OAuth client is not configured") if client_id.blank? || client_secret.blank?
        return failure("Missing authorization code") if @code.blank?

        tokens = exchange_code(client_id: client_id, client_secret: client_secret)
        return failure(tokens[:error]) unless tokens[:success]

        connection = @company.calendar_connections.find_or_initialize_by(provider: "google")
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
        uri = URI.parse(ENV.fetch("GOOGLE_OAUTH_TOKEN_URL", TOKEN_URL))
        response = Net::HTTP.post_form(uri, {
          code: @code,
          client_id: client_id,
          client_secret: client_secret,
          redirect_uri: @redirect_uri,
          grant_type: "authorization_code"
        })
        body = JSON.parse(response.body) rescue {}
        unless response.is_a?(Net::HTTPSuccess)
          return { success: false, error: body["error_description"] || body["error"] || "Google token exchange failed" }
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
