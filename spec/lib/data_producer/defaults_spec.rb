require "rails_helper"

RSpec.describe DataProducer::Defaults do
  it { expect(subject.logger).to eq Rails.logger }
  it { expect(subject.deliver).to eq false }
  it { expect(subject.client_id).to eq "Dummy" }
  it { expect(subject.keep_alive).to eq false }
  it { expect(subject.topic).to eq "data" }
  it { expect(subject.heartbeat).to eq 10 }
  it { expect(subject.aws_region).to eq "us-east-2" }

  it "doesn't break if no Rails app present" do
    allow(Rails).to receive(:application).and_raise(NoMethodError)
    expect(subject.client_id).to eq "DataProducer"
  end
end
