# frozen_string_literal: true

module DataProducer
  # Defaults provides a PORO interface to retrieve engine configuration defaults.
  # @author rebecca.chapin@fundthatflip.com
  module Defaults
    class << self
      def logger
        Rails.logger
      end

      def deliver
        false
      end

      def client_id
        Rails.application.class.module_parent.name
      rescue
        "DataProducer"
      end

      def topic
        "data"
      end

      def keep_alive
        false
      end

      def heartbeat
        10 # seconds
      end

      def aws_region
        "us-east-2"
      end
    end
  end
end
