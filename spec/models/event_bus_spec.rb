# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventBus do
  before { described_class.reset! }
  after { described_class.reset! }

  TestEvent = Class.new

  it "publishes events to subscribed listeners" do
    received = []
    described_class.subscribe(TestEvent, ->(event) { received << event })

    event = TestEvent.new
    expect(described_class.publish(event)).to eq(event)
    expect(received).to eq([ event ])
  end

  it "does not notify listeners of other event classes" do
    called = false
    described_class.subscribe(TestEvent, ->(_) { called = true })
    described_class.publish(Class.new.new)
    expect(called).to be(false)
  end
end
