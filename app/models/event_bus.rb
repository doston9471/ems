# frozen_string_literal: true

# Simple in-process event bus. Listeners register via EventBus.subscribe.
module EventBus
  class << self
    def subscribe(event_class, listener)
      listeners_for(event_class) << listener
    end

    def publish(event)
      listeners_for(event.class).each do |listener|
        listener.call(event)
      end
      event
    end

    def reset!
      @listeners = {}
    end

    private

    def listeners_for(event_class)
      (@listeners ||= {})[event_class] ||= []
    end
  end
end
