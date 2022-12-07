# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataSourcesController, type: :request do
  let(:headers) { basic_auth_headers }

  describe "when data_producer IS NOT running" do
    before do
      DataProducer.stop
    end

    context "#create" do
      let(:data_source) { build(:data_source) }
      let(:path) { data_sources_path }

      it "creates a data_source" do
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        post path, params: data_source.to_json, headers: headers
        expect_response_to_match(data_source)
      end

      it "returns error" do
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        data_source = build(:data_source, :invalid)
        post path, params: data_source.to_json, headers: headers
        expect_response_to_match(error_response)
      end
    end

    context "#show" do
      let(:data_source) { create(:data_source) }
      let(:path) { data_source_path(data_source.id) }

      it "shows a data_source" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        get path, headers: headers
        expect_response_to_match(data_source)
      end

      it "returns error" do
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        path = data_source_path("invalid_id")
        get path, headers: headers
        expect_response_to_match(error_response)
      end
    end

    context "#index" do
      let(:data_sources) { create_list(:data_source, 2) }
      let(:path) { data_sources_path }

      it "lists data_sources" do
        expect(data_sources).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        expect(data_sources.count).to eq 2
        get path, headers: headers
        expect_response_to_match_array(data_sources)
      end
    end

    context "#update" do
      let(:data_source) { create(:data_source) }
      let(:path) { data_source_path(data_source.id) }
      let(:update) { build(:data_source).attributes.except("id") }

      it "updates a data_source" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        put path, params: update.to_json, headers: headers
        expect_response_to_match(data_source)
        expect(json.values).to include(*update.values.compact)
      end

      it "fails to update" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        invalid_update = build(:data_source, :invalid)
        put path, params: invalid_update.to_json, headers: headers
        expect_response_to_match(error_response)
      end

      it "returns an error" do
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        path = data_source_path("invalid_id")
        put path, params: update.to_json, headers: headers
        expect_response_to_match(error_response)
      end
    end

    context "#destroy" do
      let(:data_source) { create(:data_source) }
      let(:path) { data_source_path(data_source.id) }

      it "deletes a data_source" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        expect(DataSource.find(data_source.id)).to be_present
        delete path, headers: headers
        expect(response.status).to eq 204
        expect(DataSource.find_by(id: data_source.id)).to_not be_present
      end

      it "returns and error" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        path = data_source_path("invalid_id")
        delete path, headers: headers
        expect_response_to_match(error_response)
      end
    end
  end

  describe "when data_producer IS running" do
    before do
      DataProducer.start
    end

    context "#create" do
      let(:data_source) { build(:data_source) }
      let(:path) { data_sources_path }

      it "creates a data_source" do
        expect_any_instance_of(DataProducer::ReportingService).to receive(:call)
        post path, params: data_source.to_json, headers: headers
        expect_response_to_match(data_source)
      end

      it "returns error" do
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        data_source = build(:data_source, :invalid)
        post path, params: data_source.to_json, headers: headers
        expect_response_to_match(error_response)
      end
    end

    context "#show" do
      let(:data_source) { create(:data_source) }
      let(:path) { data_source_path(data_source.id) }

      it "shows a data_source" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        get path, headers: headers
        expect_response_to_match(data_source)
      end

      it "returns error" do
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        path = data_source_path("invalid_id")
        get path, headers: headers
        expect_response_to_match(error_response)
      end
    end

    context "#index" do
      let(:data_sources) { create_list(:data_source, 2) }
      let(:path) { data_sources_path }

      it "lists data_sources" do
        expect(data_sources).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        expect(data_sources.count).to eq 2
        get path, headers: headers
        expect_response_to_match_array(data_sources)
      end
    end

    context "#update" do
      let(:data_source) { create(:data_source) }
      let(:path) { data_source_path(data_source.id) }
      let(:update) { build(:data_source).attributes.except("id") }

      it "updates a data_source" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).to receive(:call)
        put path, params: update.to_json, headers: headers
        expect_response_to_match(data_source)
        expect(json.values).to include(*update.values.compact)
      end

      it "fails to update" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        invalid_update = build(:data_source, :invalid)
        put path, params: invalid_update.to_json, headers: headers
        expect_response_to_match(error_response)
      end

      it "returns an error" do
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        path = data_source_path("invalid_id")
        put path, params: update.to_json, headers: headers
        expect_response_to_match(error_response)
      end
    end

    context "#destroy" do
      let(:data_source) { create(:data_source) }
      let(:path) { data_source_path(data_source.id) }

      it "deletes a data_source" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).to receive(:call)
        expect(DataSource.find(data_source.id)).to be_present
        delete path, headers: headers
        expect(response.status).to eq 204
        expect(DataSource.find_by(id: data_source.id)).to_not be_present
      end

      it "returns and error" do
        expect(data_source).to be_present
        expect_any_instance_of(DataProducer::ReportingService).not_to receive(:call)
        path = data_source_path("invalid_id")
        delete path, headers: headers
        expect_response_to_match(error_response)
      end
    end
  end
end
