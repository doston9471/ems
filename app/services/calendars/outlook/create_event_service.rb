# frozen_string_literal: true

module Calendars
  module Outlook
    class CreateEventService < ApplicationService
      API_BASE = "https://graph.microsoft.com/v1.0"

      def initialize(calendar_event:)
        @calendar_event = calendar_event
      end

      def call
        connection = find_connection
        return mark_failed!("No Outlook calendar connection for company") unless connection

        unless connection.credentials_present?
          return mark_failed!("Outlook access_token and calendar_id are required")
        end

        refresh = Calendars::Oauth::RefreshTokenService.call(connection: connection)
        connection.reload if refresh.success?

        if stub_mode?(connection.company, connection)
          return mark_synced!("stub-outlook-#{@calendar_event.id}-#{SecureRandom.hex(4)}")
        end

        response = post_event(connection)
        if response[:success]
          mark_synced!(response[:external_event_id])
        else
          mark_failed!(response[:error] || "Outlook Graph API request failed")
        end
      end

      private

      def find_connection
        CalendarConnection.enabled.find_by(
          company_id: @calendar_event.company_id,
          provider: "outlook"
        )
      end

      def stub_mode?(company, connection)
        return true if ActiveModel::Type::Boolean.new.cast(company.settings&.dig("outlook_calendar_stub"))
        return true if ActiveModel::Type::Boolean.new.cast(ENV["OUTLOOK_CALENDAR_STUB"])
        return true if connection.access_token.to_s.start_with?("placeholder") && !Rails.env.production?

        false
      end

      def post_event(connection)
        base = ENV.fetch("OUTLOOK_CALENDAR_API_BASE", API_BASE)
        calendar_segment = connection.calendar_id == "primary" ? "" : "/calendars/#{CGI.escape(connection.calendar_id)}"
        uri = URI.parse("#{base}/me#{calendar_segment}/events")
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
            { success: true, external_event_id: parsed["id"].presence || "outlook-#{@calendar_event.id}" }
          else
            { success: false, error: "Outlook Graph HTTP #{code}" }
          end
        end
      rescue StandardError => e
        { success: false, error: e.message }
      end

      def event_body
        payload = @calendar_event.payload.presence || {}
        start_payload = payload["start_datetime"] || outlook_time_from_google(payload["start"]) ||
                        { "dateTime" => Time.current.iso8601, "timeZone" => "UTC" }
        end_payload = payload["end_datetime"] || outlook_time_from_google(payload["end"], end_day: true) ||
                      { "dateTime" => 1.hour.from_now.iso8601, "timeZone" => "UTC" }

        {
          subject: payload["summary"] || payload["subject"] || "EMS event",
          body: {
            contentType: "Text",
            content: payload["description"].to_s
          },
          start: start_payload,
          end: end_payload,
          isAllDay: start_payload["dateTime"].to_s.end_with?("T00:00:00") || payload.dig("start", "date").present?
        }
      end

      def outlook_time_from_google(value, end_day: false)
        return nil if value.blank?

        if value.is_a?(Hash) && value["date"].present?
          date = Date.parse(value["date"].to_s)
          date -= 1.day if end_day # Google exclusive end date for all-day
          {
            "dateTime" => date.beginning_of_day.iso8601,
            "timeZone" => "UTC"
          }
        elsif value.is_a?(Hash) && value["dateTime"].present?
          { "dateTime" => value["dateTime"], "timeZone" => value["timeZone"].presence || "UTC" }
        end
      rescue ArgumentError
        nil
      end

      def mark_synced!(external_id)
        Rails.logger.info("[Calendars::Outlook::CreateEventService] synced calendar_event=#{@calendar_event.id} external_id=#{external_id}")
        @calendar_event.update!(
          status: "synced",
          external_event_id: external_id,
          error_message: nil,
          synced_at: Time.current
        )
        success(@calendar_event)
      end

      def mark_failed!(message)
        Rails.logger.warn("[Calendars::Outlook::CreateEventService] failed calendar_event=#{@calendar_event.id} error=#{message}")
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
