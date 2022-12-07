require "rails_helper"

RSpec.describe DataProducer::Models do
  class Mock
    include ActiveModel::Model
    extend ActiveModel::Callbacks
    extend DataProducer::Models

    define_model_callbacks :create, :update, :destroy

    attr_accessor :name

    def create
      run_callbacks :create do; end
    end

    def update
      run_callbacks :update do; end
    end

    def destroy
      run_callbacks :destroy do; end
    end

    def attributes
      {name: name}
    end
  end

  describe ".monitor" do
    before do
      DataProducer.start
    end

    context "create" do
      class MockCreate < Mock
        monitor :create
      end

      it "monitors creates" do
        mock = MockCreate.new(name: "name")
        expect(mock.respond_to?(:push_create)).to eq true
        expect(mock.respond_to?(:push_update)).to eq false
        expect(mock.respond_to?(:push_destroy)).to eq false

        expect(DataProducer::ReportingService)
          .to receive(:call)
          .with(:create, "MockCreate", mock.attributes)
        expect(DataProducer::ReportingService)
          .not_to receive(:call)
          .with(:update, "MockCreate", mock.attributes)
        expect(DataProducer::ReportingService)
          .not_to receive(:call)
          .with(:destroy, "MockCreate", mock.attributes)
        expect(mock.create).to eq nil
      end
    end

    context "update" do
      class MockUpdate < Mock
        monitor :update
      end

      it "monitors updates" do
        mock = MockUpdate.new(name: "name")
        expect(mock.respond_to?(:push_create)).to eq false
        expect(mock.respond_to?(:push_update)).to eq true
        expect(mock.respond_to?(:push_destroy)).to eq false

        expect(DataProducer::ReportingService)
          .not_to receive(:call)
          .with(:create, "MockUpdate", mock.attributes)
        expect(DataProducer::ReportingService)
          .to receive(:call)
          .with(:update, "MockUpdate", mock.attributes)
        expect(DataProducer::ReportingService)
          .not_to receive(:call)
          .with(:destroy, "MockUpdate", mock.attributes)
        expect(mock.update).to eq nil
      end
    end

    context "destroy" do
      class MockDestroy < Mock
        monitor :destroy
      end

      it "monitors destroys" do
        mock = MockDestroy.new(name: "name")
        expect(mock.respond_to?(:push_create)).to eq false
        expect(mock.respond_to?(:push_update)).to eq false
        expect(mock.respond_to?(:push_destroy)).to eq true

        expect(DataProducer::ReportingService)
          .not_to receive(:call)
          .with(:create, "MockDestroy", mock.attributes)
        expect(DataProducer::ReportingService)
          .not_to receive(:call)
          .with(:update, "MockDestroy", mock.attributes)
        expect(DataProducer::ReportingService)
          .to receive(:call)
          .with(:destroy, "MockDestroy", mock.attributes)
        expect(mock.destroy).to eq nil
      end
    end
  end
end
