# frozen_string_literal: true

require_relative "lib/data_producer/version"

Gem::Specification.new do |spec|
  spec.name = "data_producer"
  spec.version = DataProducer::VERSION
  spec.authors = ["Rebecca Chapin"]
  spec.email = ["creative@rebeccachapin.com"]
  spec.homepage = "https://github.com/rubyDoomsday"
  spec.summary = "Rails engine to observe and publish model changes to a message bus"
  spec.description = "Loops into model CRUD actions to publish changes to a message bus"
  spec.license = "MIT"
  spec.executables << "publish"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = ""

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0", ">= 6.0.3.7"

  spec.add_dependency "tty-spinner", "~> 0.9.3"
  spec.add_dependency "optparse", "~> 0.1.1"
  spec.add_dependency "concurrent-ruby", "~> 1.1", ">= 1.1.9"
  spec.add_dependency "aws-sdk-kinesis", "~> 1.36"
end
