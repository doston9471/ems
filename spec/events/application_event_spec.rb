# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationEvent do
  describe "#event_key" do
    it "underscores the class name and replaces namespaces with dots" do
      expect(described_class.new.event_key).to eq("application_event")
      expect(Leave::ApprovedEvent.new.event_key).to eq("leave.approved_event")
      expect(Employees::HiredEvent.new.event_key).to eq("employees.hired_event")
    end
  end

  describe "#payload" do
    it "exposes payload with indifferent access" do
      event = described_class.new("foo" => 1)

      expect(event.payload[:foo]).to eq(1)
      expect(event.payload["foo"]).to eq(1)
    end

    it "sets occurred_at" do
      expect(described_class.new.occurred_at).to be_within(1.second).of(Time.current)
    end
  end

  describe ".publish" do
    it "publishes a new event through EventBus" do
      published = nil
      allow(EventBus).to receive(:publish) { |event| published = event }

      result = described_class.publish(hello: "world")

      expect(EventBus).to have_received(:publish).with(an_instance_of(described_class))
      expect(published.payload[:hello]).to eq("world")
      expect(result).to eq(published)
    end
  end
end
