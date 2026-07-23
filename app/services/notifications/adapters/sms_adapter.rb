# frozen_string_literal: true

module Notifications
  module Adapters
    class SmsAdapter
      TWILIO_API = "https://api.twilio.com/2010-04-01"

      def deliver(delivery)
        phone = delivery.employee&.phone || delivery.payload["phone"]
        if phone.blank?
          Rails.logger.info("[SmsAdapter] skipped event=#{delivery.event_key} (no phone)")
          return { success: false, skipped: true, error: "No recipient phone" }
        end

        credentials = twilio_credentials(delivery.company)
        if credentials.blank?
          Rails.logger.info("[SmsAdapter] stub log to=#{phone} event=#{delivery.event_key}")
          return { success: true, skipped: false } unless Rails.env.production?

          return { success: false, skipped: true, error: "Twilio credentials not configured" }
        end

        send_twilio(phone: phone, body: message_body(delivery), credentials: credentials)
      end

      private

      def twilio_credentials(company)
        settings = company&.settings || {}
        sid = settings["twilio_account_sid"].presence || ENV["TWILIO_ACCOUNT_SID"].presence
        token = settings["twilio_auth_token"].presence || ENV["TWILIO_AUTH_TOKEN"].presence
        from = settings["twilio_from_number"].presence || ENV["TWILIO_FROM_NUMBER"].presence
        return nil if sid.blank? || token.blank? || from.blank?

        { account_sid: sid, auth_token: token, from: from }
      end

      def message_body(delivery)
        delivery.payload["message"].presence ||
          "#{delivery.event_key}: #{delivery.payload.except('message').to_json}"
      end

      def send_twilio(phone:, body:, credentials:)
        uri = URI.parse("#{TWILIO_API}/Accounts/#{credentials[:account_sid]}/Messages.json")
        request = Net::HTTP::Post.new(uri)
        request.basic_auth(credentials[:account_sid], credentials[:auth_token])
        request.set_form_data("To" => phone, "From" => credentials[:from], "Body" => body.to_s.truncate(1500))

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
          http.request(request)
        end

        if response.is_a?(Net::HTTPSuccess)
          { success: true }
        else
          parsed = JSON.parse(response.body) rescue {}
          { success: false, error: parsed["message"] || "Twilio HTTP #{response.code}" }
        end
      rescue StandardError => e
        { success: false, error: e.message }
      end
    end
  end
end
