# frozen_string_literal: true

module DataProducer
  # Hearbeat is the keep alive service manager.
  # @private
  # @author rebecca.chapin@fundthatflip.com
  class Heartbeat
    KEY = "keep_alive"
    TIMEOUT = 10 # seconds

    class << self
      # Asynchronously starts a keep_alive message event
      # @example
      #   DataProducer::Hearbeat.start_async
      def start_async
        @heartbeat ||= Concurrent::TimerTask.new(**timer_config) do
          DataProducer::PublishingService.call(payload, KEY)
        end
        @heartbeat.execute
      end

      # Closes an open keep alive task if it exists
      # @example
      #   DataProducer::Hearbeat.stop
      def stop
        @heartbeat&.shutdown
      end

      private

      def timer_config
        {
          execution_interval: DataProducer.config.heartbeat,
          timeout_interval: TIMEOUT,
        }
      end

      def payload
        {timestamp: Time.now.utc.iso8601}
      end
    end
  end
end
