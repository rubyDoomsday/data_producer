require "rails_helper"

RSpec.describe DataProducer::Heartbeat do
  before do
    DataProducer::Heartbeat.instance_variable_set(:@heartbeat, nil)
  end

  it "it can be started" do
    DataProducer.config.heartbeat = 0.01
    expect(DataProducer::PublishingService).to receive(:call).at_least(:once)
    heart_beat = described_class.start_async
    sleep 0.1
    expect(heart_beat).to be_kind_of(Concurrent::TimerTask)
    expect(heart_beat.running?).to eq true
  end

  it "it can be stopped" do
    heart_beat = described_class.start_async
    expect(described_class.stop)
    expect(heart_beat.running?).to eq false
  end
end
