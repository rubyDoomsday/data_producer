require "rails_helper"

RSpec.describe DataProducer::ReportingService do
  let(:name) { "SomeModelName" }
  let(:record) do
    {
      "id": 1,
      "first_name": "Homer",
      "last_name": "Simpson",
      "children": 2.5,
    }
  end

  it_behaves_like "an_application_service" do
    let(:args) { [:create, name, record] }
  end

  describe "class" do
    it "publishes: create" do
      result = described_class.call(:create, name, record)
      expect(result).to_not be_empty
    end

    it "publishes: update" do
      result = described_class.call(:update, name, record)
      expect(result).to_not be_empty
    end

    it "publishes: destroy" do
      result = described_class.call(:destroy, name, record)
      expect(result).to_not be_empty
    end

    it "handles a block" do
      described_class.call(:create, name, record) do |reporter|
        expect(reporter.result.keys).to eq [:name, :action, :attributes]
        expect(reporter.result[:attributes]).to eq record
      end
    end
  end
end
