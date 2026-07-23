# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :company
  attribute :membership
  attribute :employee

  delegate :user, to: :session, allow_nil: true

  resets { ActsAsTenant.current_tenant = nil }

  def company=(value)
    super
    ActsAsTenant.current_tenant = value
  end
end
