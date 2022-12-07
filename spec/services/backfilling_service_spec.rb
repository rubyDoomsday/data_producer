require "rails_helper"

RSpec.describe DataProducer::BackfillingService do
  let(:model_name) { "DataSource" }

  it_behaves_like "an_application_service" do
    let(:args) { [model_name, Time.now.utc, Time.now.utc] }
  end

  describe "class" do
    before do
      create(:data_source, created_at: Time.now.utc - 1.day)
      create(:data_source, created_at: Time.now.utc)
      create(:data_source, created_at: Time.now.utc + 1.day)
    end

    it "backfills data up to present" do
      start_date = Time.now.utc - 3.days
      args = [model_name, start_date]
      expect(DataProducer::ReportingService).to receive(:call).twice
      described_class.call(*args)
    end

    it "backfills data up to provided end_date" do
      start_date = Time.now.utc - 3.days
      end_date = Time.now.utc + 3.days
      args = [model_name, start_date, end_date]
      expect(DataProducer::ReportingService).to receive(:call).exactly(3).times
      described_class.call(*args)
    end

    it "ignores a class that doesn't exist" do
      expect(DataProducer::ReportingService).to_not receive(:call)
      expect { described_class.call("Invalid") }.not_to raise_error
    end

    it "only processes monitored models" do
      expect(DataProducer::ReportingService).to_not receive(:call)
      expect { described_class.call("DataSourcesController") }.not_to raise_error
    end

    it "fails with error if no records are found" do
      start_date = Time.now.utc - 10.days
      end_date = Time.now.utc - 9.days
      args = [model_name, start_date, end_date]
      expect(DataProducer::ReportingService).to_not receive(:call)
      described_class.call(*args) do |s|
        expect(s.failed?).to eq true
        expect(s.errors.first).to be_kind_of(ArgumentError)
      end
    end
  end
end
