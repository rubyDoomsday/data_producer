# frozen_string_literal: true

module DataProducer
  # Models exposes a DSL for ActiveRecord Models.
  # @author rebecca.chapin@fundthatflip.com
  module Models
    # Exposes a configuration method for ActiveRecord Models that listens for
    #   CRUD actions. When one of the observed actions is triggered the
    #   corresponding concern will trap the changes and report them out to
    #   downstream services.
    #
    # @note This is automatically available to any class that inherits from ActiveRecord
    #
    # @param [Array] actions The actions to be observed on the given model
    # @option actions [Symbol] :create Monitors for create record actions
    # @option actions [Symbol] :update Monitors for update record actions
    # @option actions [Symbol] :destroy Monitors for destroy record actions
    #
    # @example Monitor Actions
    #   monitor :create, :update, :destroy
    def monitor(*actions)
      config = load_config(actions)

      config.concerns.each do |concern|
        include concern
      end
    end

    private

    def load_config(actions = [])
      DataProducer::ModelConfig.new(*actions)
    end
  end
end
