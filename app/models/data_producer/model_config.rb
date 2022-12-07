# frozen_string_literal: true

module DataProducer
  # ModelConfig provides a PORO interface for processing actions
  # @author rebecca.chapin@fundthatflip.com
  class ModelConfig
    class ConfigError < ArgumentError; end

    # Actions manages supported actions that can be processed by the engine
    # @private
    module Actions
      ALL = [
        CREATE = :create,
        UPDATE = :update,
        DESTROY = :destroy,
      ]

      # Validates a list of actions
      #
      # @param [Array] actions List of symbolized action names
      # @return [Boolean] If the list contains an invalid action result is false
      #
      # @example Validate Actions
      #   Actions.valid?([:create, :update, :invalid])
      def self.valid?(actions)
        actions.reject { |a| all.include?(a) }.empty?
      end

      # Accessor for all available actions
      # @return [Array] Symbolized names of supported actions
      def self.all
        ALL
      end
    end

    attr_reader :actions

    # Proxy accessor for all supported actions. This should be used for external callers
    # @return [Array] List of support actions
    def self.all_actions
      Actions.all
    end

    # @param [Array] actions The list of actions. This could be strings or symbols
    # @note All provided actions will be converted to symbols
    # @raise [ModelConfig::ConfigError] if any of the provided actions are unsupported
    def initialize(*actions)
      msg = "Invalid action provided: #{actions}"

      @actions = actions.map(&:to_sym).uniq
      raise ConfigError, msg unless Actions.valid?(@actions)
    end

    # Translates the list of provided actions to its corresponding Concern
    # @return [Array] [Action]Concern class if it is supported
    # @example
    #   config.concerns #=> [CreateConcern, UpdateConcern]
    def concerns
      actions.map do |a|
        name = a.to_s.classify
        DataProducer.const_get("#{name}Concern")
      end
    end

    def create?
      actions.include?(Actions::CREATE)
    end

    def update?
      actions.include?(Actions::UPDATE)
    end

    def destroy?
      actions.include?(Actions::DESTROY)
    end
  end
end
