require "rails_helper"

RSpec.describe DataProducer::ApplicationService do
  describe "interface" do
    it "does not expose initialise" do
      expect { described_class.new }.to raise_error(NoMethodError)
    end

    it "exposes .call" do
      expect(described_class.call).to eq nil
    end

    it "accepts a block" do
      described_class.call do |service|
        expect(service.success?).to eq true
        expect(service.failed?).to eq false
        expect(service.errors).to eq []
        expect(service.result).to eq nil
      end
    end
  end
end
