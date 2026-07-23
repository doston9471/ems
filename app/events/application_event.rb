# frozen_string_literal: true

class ApplicationEvent
  attr_reader :payload, :occurred_at

  def initialize(payload = {})
    @payload = payload.to_h.with_indifferent_access
    @occurred_at = Time.current
  end

  def event_key
    self.class.name.underscore.tr("/", ".")
  end

  def self.publish(payload = {})
    EventBus.publish(new(payload))
  end
end
