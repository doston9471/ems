# frozen_string_literal: true

module Notifications
  module Adapters
    class SlackAdapter
      def deliver(delivery)
        url = webhook_url(delivery.company)
        if url.blank?
          Rails.logger.info("[SlackAdapter] skipped event=#{delivery.event_key} company=#{delivery.company_id} (no webhook URL)")
          return { success: false, skipped: true, error: "Slack webhook URL not configured" }
        end

        body = {
          text: "EMS notification: #{delivery.event_key}",
          blocks: [
            { type: "section", text: { type: "mrkdwn", text: "*#{delivery.event_key}*\n```#{delivery.payload.to_json}```" } }
          ]
        }

        post_json(url, body)
        { success: true }
      rescue StandardError => e
        { success: false, error: e.message }
      end

      private

      def webhook_url(company)
        company.settings&.dig("slack_webhook_url").presence || ENV["SLACK_WEBHOOK_URL"].presence
      end

      def post_json(url, body)
        uri = URI.parse(url)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5) do |http|
          request = Net::HTTP::Post.new(uri)
          request["Content-Type"] = "application/json"
          request.body = body.to_json
          response = http.request(request)
          raise "Slack HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)
        end
      end
    end
  end
end
