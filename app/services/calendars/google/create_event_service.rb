# frozen_string_literal: true

module Calendars
  module Google
    class CreateEventService < ApplicationService
      API_BASE = "https://www.googleapis.com/calendar/v3"

      def initialize(calendar_event:)
        @calendar_event = calendar_event
      end

      def call
        connection = find_connection
        return mark_failed!("No Google calendar connection for company") unless connection

        unless connection.credentials_present?
          return mark_failed!("Google Calendar access_token and calendar_id are required")
        end

        refresh = Calendars::Oauth::RefreshTokenService.call(connection: connection)
        connection.reload if refresh.success?

        if stub_mode?(connection.company, connection)
          return mark_synced!("stub-google-#{@calendar_event.id}-#{SecureRandom.hex(4)}")
        end

        response = post_event(connection)
        if response[:success]
          mark_synced!(response[:external_event_id])
        else
          mark_failed!(response[:error] || "Google Calendar API request failed")
        end
      end

      private

      def find_connection
        CalendarConnection.enabled.find_by(
          company_id: @calendar_event.company_id,
          provider: "google"
        )
      end

      def stub_mode?(company, connection)
        return true if ActiveModel::Type::Boolean.new.cast(company.settings&.dig("google_calendar_stub"))
        return true if ActiveModel::Type::Boolean.new.cast(ENV["GOOGLE_CALENDAR_STUB"])
        return true if connection.access_token.to_s.start_with?("placeholder") && !Rails.env.production?

        false
      end

      def post_event(connection)
        base = ENV.fetch("GOOGLE_CALENDAR_API_BASE", API_BASE)
        uri = URI.parse("#{base}/calendars/#{CGI.escape(connection.calendar_id)}/events")
        body = event_body.to_json

        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 10) do |http|
          request = Net::HTTP::Post.new(uri)
          request["Authorization"] = "Bearer #{connection.access_token}"
          request["Content-Type"] = "application/json"
          request.body = body
          response = http.request(request)
          code = response.code.to_i
          if response.is_a?(Net::HTTPSuccess)
            parsed = JSON.parse(response.body) rescue {}
            { success: true, external_event_id: parsed["id"].presence || "google-#{@calendar_event.id}" }
          else
            { success: false, error: "Google Calendar HTTP #{code}" }
          end
        end
      rescue StandardError => e
        { success: false, error: e.message }
      end

      def event_body
        payload = @calendar_event.payload.presence || {}
        {
          summary: payload["summary"] || "EMS event",
          description: payload["description"],
          start: payload["start"] || { date: Date.current.iso8601 },
          end: payload["end"] || { date: (Date.current + 1).iso8601 }
        }
      end

      def mark_synced!(external_id)
        Rails.logger.info("[Calendars::Google::CreateEventService] synced calendar_event=#{@calendar_event.id} external_id=#{external_id}")
        @calendar_event.update!(
          status: "synced",
          external_event_id: external_id,
          error_message: nil,
          synced_at: Time.current
        )
        success(@calendar_event)
      end

      def mark_failed!(message)
        Rails.logger.warn("[Calendars::Google::CreateEventService] failed calendar_event=#{@calendar_event.id} error=#{message}")
        @calendar_event.update!(
          status: "failed",
          error_message: message,
          synced_at: nil
        )
        failure(message)
      end
    end
  end
end
