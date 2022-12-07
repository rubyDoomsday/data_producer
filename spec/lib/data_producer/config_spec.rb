require "rails_helper"

RSpec.describe DataProducer::Config do
  describe "instance" do
    it "does not require config opts" do
      config = described_class.new
      expect(config.deliver).to eq false
      expect(config.kinesis_host).to eq nil
      expect(config.client_id).to eq "Dummy"
      expect(config.logger).to eq Rails.logger
      expect(config.keep_alive).to eq false
      expect(config.topic).to eq "data"
      expect(config.heartbeat).to eq 10
      expect(config.aws_access_key_id).to eq nil
      expect(config.aws_secret_access_key).to eq nil
      expect(config.aws_region).to eq "us-east-2"
    end

    it "accepts deliver" do
      opts = {deliver: true}
      expect(described_class.new(opts).deliver).to eq true
    end

    it "accepts logger" do
      FakeLogger = OpenStruct.new(error: true, info: true)
      opts = {logger: FakeLogger}
      expect(described_class.new(opts).logger).to eq FakeLogger
    end

    it "accepts kinesis_host" do
      opts = {kinesis_host: "kinesis:4568"}
      expect(described_class.new(opts).kinesis_host).to eq opts[:kinesis_host]
    end

    it "accepts client_id" do
      opts = {client_id: "ImAClient"}
      expect(described_class.new(opts).client_id).to eq opts[:client_id]
    end

    it "accepts topic" do
      opts = {topic: "aTopic"}
      expect(described_class.new(opts).topic).to eq opts[:topic]
    end

    it "accepts keep_alive" do
      opts = {keep_alive: true}
      expect(described_class.new(opts).keep_alive).to eq opts[:keep_alive]
    end

    it "accepts hearbeat" do
      opts = {heartbeat: 10}
      expect(described_class.new(opts).heartbeat).to eq opts[:heartbeat]
    end

    it "accepts aws_region" do
      opts = {aws_region: "us-east-1"}
      expect(described_class.new(opts).aws_region).to eq opts[:aws_region]
    end

    it "accepts aws_secret_access_key" do
      opts = {aws_secret_access_key: "secret"}
      expect(described_class.new(opts).aws_secret_access_key).to eq opts[:aws_secret_access_key]
    end

    it "accepts aws_access_key_id" do
      opts = {aws_access_key_id: "access"}
      expect(described_class.new(opts).aws_access_key_id).to eq opts[:aws_access_key_id]
    end
  end

  describe "configurations" do
    it "supplies an AWS configuration" do
      opts = {
        aws_access_key_id: "access",
        aws_secret_access_key: "secret",
        kinesis_host: "locahost:4568",
        deliver: true,
        aws_region: "us-east-1",
      }

      config = described_class.new(opts)
      result = {
        region: opts[:aws_region],
        credentials: config.send(:aws_credentials),
        endpoint: opts[:kinesis_host],
        stub_responses: !opts[:deliver],
      }

      expect(config.message_bus).to eq result
    end
  end

  describe "validations" do
    it "validates deliver" do
      opts = {deliver: ""}
      expect { described_class.new(opts) }.to raise_error(ArgumentError)
    end

    it "validates logger" do
      opts = {logger: OpenStruct.new}
      expect { described_class.new(opts) }.to raise_error(ArgumentError)
    end

    it "validates kinesis host" do
      opts = {kinesis_host: 1}
      expect { described_class.new(opts) }.to raise_error(ArgumentError)
    end

    it "validates client id" do
      opts = {client_id: 1}
      expect { described_class.new(opts) }.to raise_error(ArgumentError)
    end

    it "validates config options" do
      opts = {invalid: nil}
      expect { described_class.new(opts) }.to raise_error(DataProducer::ConfigError)
    end

    it "validates keep alive" do
      opts = {keep_alive: ""}
      expect { described_class.new(opts) }.to raise_error(ArgumentError)
    end

    it "validates topic" do
      opts = {topic: 123}
      expect { described_class.new(opts) }.to raise_error(ArgumentError)
    end

    it "validates hearbeat" do
      opts = {heartbeat: "ten"}
      expect { described_class.new(opts) }.to raise_error(ArgumentError)
    end
  end
end
