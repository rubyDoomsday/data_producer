# frozen_string_literal: true

require "factory_bot_rails"

FactoryBot.definition_file_paths << File.join(ENGINE_ROOT, "spec", "factories")

RSpec.configure do |c|
  c.include FactoryBot::Syntax::Methods

  c.before(:suite) do
    FactoryBot.find_definitions
  end
end
