require "rails_helper"

RSpec.describe DataProducer::PublishingService do
  let(:topic) { "aTopic" }
  let(:data) do
    {
      "id": 1,
      "first_name": "Homer",
      "last_name": "Simpson",
      "children": 2.5,
    }
  end

  it_behaves_like "an_application_service" do
    let(:args) { [data, topic] }
  end

  describe "class" do
    it "validates arguments" do
      expect { described_class.call("invalid") }.to raise_error(ArgumentError)
    end

    it "publishes data" do
      expect(described_class.call(data)).to be_truthy
      expect(described_class.call(data, topic)).to be_kind_of(Seahorse::Client::Response)
    end

    context "#client" do
      it "sends data" do
        kinesis_client = double("kinesis_client")
        allow_any_instance_of(described_class).to receive(:client).and_return(kinesis_client)

        response = double("response", error: nil)
        expect(kinesis_client).to receive(:put_record).and_return(response)
        described_class.call(data) do |service|
          expect(service.success?).to eq true
        end
      end

      it "handles error" do
        kinesis_client = double("kinesis_client")
        allow_any_instance_of(described_class).to receive(:client).and_return(kinesis_client)

        expect(Rails.logger).to receive(:error)
        expect(kinesis_client).to receive(:put_record).and_raise(StandardError.new("failed"))
        described_class.call(data) do |service|
          expect(service.success?).to eq false
          expect(service.errors.count).to eq 1
          expect(service.errors.first.message).to eq "failed"
        end
      end
    end
  end
end
