# frozen_string_literal: true

module DataProducer
  # PublishingService is a wrapper class to decouple the engine from the underlying Kafka library.
  # It exposes an interface for publishing a data payload onto the Kafka message bus.
  # @author rebecca.chapin@fundthatflip.com
  class PublishingService < DataProducer::ApplicationService
    DEFAULT = "default"

    private

    attr_reader :payload, :partition_key

    # @param [Hash] payload JSON parsable hash map containing the message details
    # @param [String] partition_key The partition_key ensures related data lands
    #   on the correct partition for a topic. Default "default"
    # @note partition_key should be used as a unique identifier for the configured topic
    def initialize(payload, partition_key = DEFAULT)
      raise ArgumentError, "invalid payload" unless payload.is_a?(Hash)

      @payload = payload.merge(client_info).to_json
      @partition_key = partition_key
    end

    def call
      Rails.logger.info(message: "publish kinesis message", payload: message)
      @result = client.put_record(message)
    rescue => e
      Rails.logger.error(service: self.class.name, error: e)
      errors << e
    end

    def message
      {
        stream_name: stream_name,
        partition_key: partition_key,
        data: payload,
      }
    end

    def client_info
      {
        source: DataProducer.client_id,
      }
    end

    def client
      @client ||= DataProducer.client
    end

    def stream_name
      DataProducer.config.topic
    end
  end
end
