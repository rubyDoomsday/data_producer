# frozen_string_literal: true

require "aws-sdk-kinesis"
require "data_producer/version"
require "data_producer/engine"
require "data_producer/defaults"
require "data_producer/config"
require "data_producer/heart_beat"

# DataProducer is a rails engine that once installed observes models on the host application for
# CRUD actions. When a recognized action occurs the resulting changes are reported out to configured
# message bus (Kafka).
# @author creative@rebeccachapin.com
module DataProducer
  class << self
    # The Engine configuration
    # @return [DataProducer::Config] The singleton configuration for the engine
    # @example
    #   DataProducer.config #=> <DataProducer::Configx1234>
    def config
      @config ||= DataProducer::Config.new
    end

    # The configuration interface
    # @yield [DataProducer::Config]
    # @example
    #   DataProducer.config do |c|
    #     c.deliver = true
    #   end
    def configure
      yield config
    end

    # Starts the Data Producer engine. If this is not called then models marked
    #   with monitor will not automatically report out to the message bus. This
    #   provied an explicit requirement to start monitoring data.
    # @return [Boolean] true if the engine starts up successfully
    def start
      heartbeat.start_async if config.keep_alive
      start_monitoring
      true
    rescue => e
      config.logger.error(e)
      false
    end

    # Stops the Data Producer engine from taking any observable action
    # @return [Boolean] true if the engine stops successfully
    def stop
      heartbeat.stop if config.keep_alive
      stop_monitoring
      true
    end

    def report?
      @observe
    end

    def client
      @client ||= Aws::Kinesis::Client.new(config.message_bus)
    end

    delegate :logger, :client_id, to: :config

    private

    def heartbeat
      DataProducer::Heartbeat
    end

    def start_monitoring
      @observe = true
    end

    def stop_monitoring
      @observe = false
    end
  end
end
