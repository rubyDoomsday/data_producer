# frozen_string_literal: true

require "optparse"
require "tty-spinner"

namespace :dp do # rubocop:disable Metrics/BlockLength
  desc "Publishes the desired data to the message bus"
  task backfill: :environment do # rubocop:disable Metrics/BlockLength
    # Parse Arguments
    options = {models: []}
    opts = OptionParser.new
    opts.banner = "Usage: bundle exec rake dp:backfill [options]"
    opts.on("-m", "--model NAME") { |v| options[:models].push(v) }
    opts.on("-s", "--start DATE") { |v| options[:start_time] = v }
    opts.on("-e", "--end DATE") { |v| options[:end_time] = v }
    args = opts.order!(ARGV) {}
    opts.parse!(args)

    # Define Variables
    start_time = options.fetch(:start_time, Time.current - 1.week).to_time.utc.beginning_of_day
    end_time = options.fetch(:end_time, Time.current).to_time.utc.end_of_day
    models = options[:models].uniq.sort
    service = DataProducer::BackfillingService

    # Redirect logging
    spinner = TTY::Spinner.new("[:spinner] :message", format: :spin_3)
    spin_logger = Struct.new(:spinner) do
      def info(msg)
        spinner.update(message: Array(msg).join(" "))
        Rails.logger.send(__callee__, msg)
      end
      alias_method :debug, :info
      alias_method :error, :info
      alias_method :warn, :info
    end
    DataProducer.config.logger = spin_logger.new(spinner)

    # Run Backfill
    models.each do |model|
      spinner.update(message: "Publishing #{model} Data...")
      spinner.run do
        service.call(model, start_time, end_time) do |s|
          if s.failed?
            spinner.error(s.errors.map(&:message).join(", "))
          else
            spinner.success("Done!")
          end
        end
      end
    end

    exit
  end
end
