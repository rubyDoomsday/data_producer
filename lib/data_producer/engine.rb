# frozen_string_literal: true

module DataProducer
  # Internal engine configuration details
  # @private
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.api_only = true
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: "spec/factories"
    end
  end
end
