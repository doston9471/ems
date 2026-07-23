# frozen_string_literal: true

class NotificationDeliveryPolicy < ApplicationPolicy
  def index?
    allowed?("notifications.read") || allowed?("notifications.manage")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless membership&.allows?("notifications.read") || membership&.allows?("notifications.manage")

      company_scope
    end
  end
end
