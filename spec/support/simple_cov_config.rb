# frozen_string_literal: true

if ENV["COVER"] == "true" || ENV["CI"]
  require "simplecov"
  require "active_support/core_ext/numeric/time"

  puts "simplecov runnnig..."

  SimpleCov.profiles.define :ftf_engine do
    dummy_app = "spec/dummy/app"
    enable_coverage ENV.fetch("COVERAGE_METHOD", "line").to_sym

    track_files "{app,config,lib}/**/*.rb"
    track_files "#{dummy_app}/**/*.rb"

    add_filter "lib/data_producer/version"
    add_filter "vendor"
    add_filter "app/models/data_producer/application_record.rb"
    add_filter "app/controllers/data_producer/application_controller.rb"

    add_filter "#{dummy_app}/controllers/application_controller.rb"
    add_filter "#{dummy_app}/models/application_record.rb"
    add_filter "#{dummy_app}/channels"

    add_filter "db/migrate"
    add_filter "vendor/"
    add_filter "extjs/"
    add_filter "spec/support"
    add_filter "spec/factories"

    add_group "Controllers", "app/controllers"
    add_group "Helpers", "app/helpers"
    add_group "Models", "app/models"
    add_group "Services", "app/services"
    add_group "Configs", "config/"
    add_group "Libraries", "lib/"

    use_merging true
    merge_timeout 1.day
  end

  SimpleCov.start :ftf_engine

  SimpleCov.at_exit do
    SimpleCov.result.format!
    SimpleCov.minimum_coverage 90
    SimpleCov.minimum_coverage_by_file 70
  end
end
