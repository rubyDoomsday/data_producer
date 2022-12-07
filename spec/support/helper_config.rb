# frozen_string_literal: true

# Include all helpers
Dir[Rails.root.join("..", "support", "helpers", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include LoremIpsum
  config.include RequestHelper, type: :request

  config.before do
    ConfigHelper.reset
  end
end
