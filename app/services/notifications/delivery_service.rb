# frozen_string_literal: true

module Notifications
  class DeliveryService < ApplicationService
    DEFAULT_CHANNELS = %w[email slack teams sms telegram in_app].freeze

    def initialize(company:, event_key:, payload:, employee_id: nil, user_id: nil, channels: nil)
      @company = company
      @event_key = event_key.to_s
      @payload = payload.to_h.with_indifferent_access
      @employee_id = employee_id
      @user_id = user_id
      @channels = Array(channels.presence || DEFAULT_CHANNELS).map(&:to_s)
    end

    def call
      deliveries = enabled_channels.map { |channel| deliver_channel(channel) }
      success(deliveries)
    end

    private

    def enabled_channels
      user = User.find_by(id: resolve_user_id)
      return @channels if user.blank?

      @channels.select { |channel| user.notification_channel_enabled?(channel) }
    end

    def deliver_channel(channel)
      delivery = NotificationDelivery.create!(
        company: @company,
        user_id: resolve_user_id,
        employee_id: @employee_id,
        channel: channel,
        event_key: @event_key,
        payload: @payload,
        status: "pending"
      )

      adapter = adapter_for(channel)
      result = adapter.deliver(delivery)

      if result[:success]
        delivery.update!(status: "sent", sent_at: Time.current, error_message: nil)
      else
        delivery.update!(status: result[:skipped] ? "skipped" : "failed", error_message: result[:error])
      end

      delivery
    rescue StandardError => e
      delivery&.update(status: "failed", error_message: e.message)
      raise
    end

    def adapter_for(channel)
      case channel
      when "email" then Adapters::EmailAdapter.new
      when "slack" then Adapters::SlackAdapter.new
      when "teams" then Adapters::TeamsAdapter.new
      when "sms" then Adapters::SmsAdapter.new
      when "telegram" then Adapters::TelegramAdapter.new
      when "in_app" then Adapters::InAppAdapter.new
      else
        raise ArgumentError, "Unknown notification channel: #{channel}"
      end
    end

    def resolve_user_id
      return @user_id if @user_id.present?
      return nil if @employee_id.blank?

      Employee.find_by(id: @employee_id)&.user_id
    end
  end
end
