# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataProducer do
  it "has a default config" do
    expect(DataProducer.config).to be_kind_of(DataProducer::Config)
  end

  it "can be configured" do
    logger = OpenStruct.new(info: true, error: true)
    kinesis_host = "kinesis:4568"
    client_id = "TestID"
    DataProducer.configure do |c|
      expect(c.deliver = true).to be_truthy
      expect(c.logger = logger).to be_truthy
      expect(c.kinesis_host = kinesis_host).to be_truthy
      expect(c.client_id = client_id).to be_truthy
      expect { c.invalid = true }.to raise_error(NoMethodError)
    end
    expect(DataProducer.config.deliver).to eq true
    expect(DataProducer.logger).to eq logger
    expect(DataProducer.config.message_bus).to eq({
      endpoint: kinesis_host,
      region: "us-east-2",
      stub_responses: false,
    })
  end

  describe ".start" do
    it "starts the heartbeat" do
      DataProducer.config.keep_alive = true
      expect(DataProducer::Heartbeat).to receive(:start_async)
      expect(DataProducer.start).to eq true
    end

    it "doesn't start a heartbeat" do
      DataProducer.config.keep_alive = false
      expect(DataProducer::Heartbeat).not_to receive(:start_async)
      expect(DataProducer.start).to eq true
    end

    it "turns on reporting" do
      expect(DataProducer).to receive(:start_monitoring)
      expect(DataProducer.start).to eq true
    end

    it "observes" do
      expect(DataProducer.start).to eq true
      expect(DataProducer.report?).to eq true
    end

    it "doesn't start" do
      DataProducer.config.keep_alive = true
      allow(DataProducer::Heartbeat)
        .to receive(:start_async).and_raise(StandardError)
      expect(DataProducer.start).to eq false
    end
  end

  describe ".stop" do
    it "stops the service" do
      DataProducer.config.keep_alive = true
      expect(DataProducer::Heartbeat).to receive(:stop)
      expect(DataProducer.stop).to eq true
      expect(DataProducer.report?).to eq false
    end
  end
end
