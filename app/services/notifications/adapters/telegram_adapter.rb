# frozen_string_literal: true

require "net/http"
require "json"

module Notifications
  module Adapters
    class TelegramAdapter
      API_BASE = "https://api.telegram.org"

      def deliver(delivery)
        token = bot_token(delivery.company)
        chat_id = chat_id_for(delivery)

        if token.blank?
          Rails.logger.info("[TelegramAdapter] skipped event=#{delivery.event_key} (no bot token)")
          return { success: false, skipped: true, error: "Telegram bot token not configured" }
        end

        if chat_id.blank?
          Rails.logger.info("[TelegramAdapter] skipped event=#{delivery.event_key} (no chat_id)")
          return { success: false, skipped: true, error: "No Telegram chat_id" }
        end

        text = [
          "EMS notification: #{delivery.event_key}",
          delivery.payload["message"].presence,
          "```#{delivery.payload.to_json}```"
        ].compact.join("\n")

        send_message(token: token, chat_id: chat_id, text: text)
        { success: true }
      rescue StandardError => e
        { success: false, error: e.message }
      end

      private

      def bot_token(company)
        company.settings&.dig("telegram_bot_token").presence || ENV["TELEGRAM_BOT_TOKEN"].presence
      end

      def chat_id_for(delivery)
        delivery.payload["telegram_chat_id"].presence ||
          delivery.payload["chat_id"].presence ||
          delivery.company.settings&.dig("telegram_chat_id").presence ||
          ENV["TELEGRAM_CHAT_ID"].presence
      end

      def send_message(token:, chat_id:, text:)
        uri = URI.parse("#{API_BASE}/bot#{token}/sendMessage")
        Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 5) do |http|
          request = Net::HTTP::Post.new(uri)
          request["Content-Type"] = "application/json"
          request.body = {
            chat_id: chat_id,
            text: text,
            parse_mode: "Markdown"
          }.to_json
          response = http.request(request)
          raise "Telegram HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
        end
      end
    end
  end
end
