# frozen_string_literal: true

module Webhooks
  class DispatchService < ApplicationService
    def initialize(company_id:, event_key:, payload:)
      @company_id = company_id
      @event_key = event_key.to_s
      @payload = payload.to_h
    end

    def call
      company = Company.find(@company_id)
      deliveries = []

      ActsAsTenant.with_tenant(company) do
        Webhook.active.where(company_id: company.id).find_each do |webhook|
          next unless webhook.listens_to?(@event_key)

          deliveries << deliver(webhook)
        end
      end

      success(deliveries)
    end

    private

    def deliver(webhook)
      delivery = webhook.webhook_deliveries.create!(
        event_key: @event_key,
        payload: @payload,
        status: "pending",
        attempts: 0
      )

      response = http_post(webhook)
      delivery.update!(
        status: response[:success] ? "delivered" : "failed",
        response_code: response[:code],
        attempts: 1,
        error_message: response[:error],
        delivered_at: response[:success] ? Time.current : nil
      )
      delivery
    rescue StandardError => e
      delivery&.update(status: "failed", attempts: 1, error_message: e.message)
      delivery
    end

    def http_post(webhook)
      uri = URI.parse(webhook.url)
      body = {
        event: @event_key,
        payload: @payload,
        delivered_at: Time.current.iso8601
      }.to_json

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 10) do |http|
        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
        request["X-EMS-Event"] = @event_key
        request["X-EMS-Signature"] = OpenSSL::HMAC.hexdigest("SHA256", webhook.secret, body)
        request.body = body
        response = http.request(request)
        code = response.code.to_i
        if response.is_a?(Net::HTTPSuccess)
          { success: true, code: code }
        else
          { success: false, code: code, error: "HTTP #{code}" }
        end
      end
    rescue StandardError => e
      { success: false, code: nil, error: e.message }
    end
  end
end
