# frozen_string_literal: true

require_relative "support/simple_cov_config"

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("./dummy/config/environment", __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!
ENGINE_ROOT = File.join(File.dirname(__FILE__), "../")

# Support Configs
require_relative "support/factory_bot_config"
require_relative "support/should_matcher_config"
require_relative "support/helper_config"
require_relative "support/shared_config"

begin
  ActiveRecord::Migrator.migrations_paths = File.join(ENGINE_ROOT, "spec/dummy/db/migrate")
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
