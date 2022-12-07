require "rails_helper"

RSpec.describe DataProducer::ModelConfig do
  it "validates actions" do
    named_error = DataProducer::ModelConfig::ConfigError
    expect { described_class.new(:invalid) }.to raise_error(named_error)
  end

  it "strips out duplicate actions" do
    actions = %i[create create update update]
    expect(actions.length).to eq 4
    config = described_class.new(*actions)
    expect(config.actions.length).to eq 2
    expect(config.actions).to match_array([:create, :update])
  end

  it "symbolizes provided actions" do
    actions = %w[create update]
    expect(actions.first).to be_kind_of(String)
    config = described_class.new(*actions)
    expect(config.actions.first).to be_kind_of(Symbol)
  end

  describe "class" do
    it "has relevant actions" do
      supported_actions = [:create, :update, :destroy]
      expect(DataProducer::ModelConfig.all_actions).to eq supported_actions
    end
  end

  describe "instance" do
    it "#create?" do
      config = described_class.new(:create)
      expect(config.create?).to eq true
      config = described_class.new(:update)
      expect(config.create?).to eq false
    end

    it "#update?" do
      config = described_class.new(:update)
      expect(config.update?).to eq true
      config = described_class.new(:create)
      expect(config.update?).to eq false
    end

    it "#destroy?" do
      config = described_class.new(:destroy)
      expect(config.destroy?).to eq true
      config = described_class.new(:update)
      expect(config.destroy?).to eq false
    end
  end
end
