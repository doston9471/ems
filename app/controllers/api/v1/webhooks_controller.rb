# frozen_string_literal: true

module Api
  module V1
    class WebhooksController < BaseController
      before_action :set_webhook, only: %i[show update destroy]

      def index
        authorize Webhook
        @webhooks = policy_scope(Webhook).order(:id)
        render json: @webhooks.as_json(only: %i[id url event_keys active created_at updated_at])
      end

      def show
        authorize @webhook
        render json: @webhook.as_json(only: %i[id url event_keys active created_at updated_at])
      end

      def create
        @webhook = Current.company.webhooks.new(webhook_params.merge(secret: SecureRandom.hex(24)))
        authorize @webhook
        if @webhook.save
          render json: @webhook.as_json(only: %i[id url secret event_keys active created_at]), status: :created
        else
          render json: { errors: @webhook.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize @webhook
        if @webhook.update(webhook_params)
          render json: @webhook.as_json(only: %i[id url event_keys active updated_at])
        else
          render json: { errors: @webhook.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @webhook
        @webhook.destroy!
        head :no_content
      end

      private

      def set_webhook
        @webhook = policy_scope(Webhook).find(params[:id])
      end

      def webhook_params
        params.require(:webhook).permit(:url, :active, event_keys: [])
      end
    end
  end
end
