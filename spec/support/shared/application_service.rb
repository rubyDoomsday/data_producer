# frozen_string_literal: true

RSpec.shared_examples "an_application_service" do
  let(:service) { described_class.send(:new, *args) }

  it { expect(described_class.respond_to?(:call)).to eq true }
  it { expect(service.respond_to?(:success?)).to eq true }
  it { expect(service.respond_to?(:failed?)).to eq true }
  it { expect(service.respond_to?(:result)).to eq true }
  it { expect(service.respond_to?(:errors)).to eq true }
  it { expect(service.errors).to eq [] }
  it { expect(service.result).to eq nil }

  it "handles a block" do
    expect_any_instance_of(described_class).to receive(:call)
    described_class.call(*args) do |s|
      expect(s.result).to eq nil
    end
  end
end
