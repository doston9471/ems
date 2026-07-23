# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :require_company!

  def index
    authorize NotificationDelivery
    @deliveries = policy_scope(NotificationDelivery).order(created_at: :desc).limit(100)
  end
end
