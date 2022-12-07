# frozen_string_literal: true

module DataProducer
  # ReportingService is the interface used to build a action based message.
  # This it the owner of the payload structure that makes its way onto the
  # message bus. Changes here will be reflected in the payload of an event.
  # @author rebecca.chapin@fundthatflip.com
  class ReportingService < DataProducer::ApplicationService
    UNKNOWN = "Unknown"

    private

    def call
      publisher.call(message, name) do |service|
        if service.success?
          @result = message
        end
      end
    end

    attr_reader :action, :name, :attributes

    # @param [Symbol] action The action that triggered an event
    # @param [String] name (optional) The name of the model. default: "Unknown"
    # @param [Hash] attributes The hash map of the model data
    def initialize(action, name = UNKNOWN, attributes = {})
      @action = action
      @name = name
      @attributes = attributes
    end

    # Message is a downstream public contract. It is important to mark all
    # breaking changes with a major version change of the engine.
    # @return [Hash] The key:value pairings of details to be reported downstream
    def message
      {
        name: name,
        action: action,
        attributes: attributes,
      }
    end

    def publisher
      @publisher ||= DataProducer::PublishingService
    end
  end
end
