# frozen_string_literal: true

module DataProducer
  # BackfillingService provides an API to report on data models created during a
  # speified time period. If no start and/or end time is provided the service
  # provides a default.
  # @author rebecca.chapin@fundthatflip.com
  class BackfillingService < DataProducer::ApplicationService
    private

    attr_reader :model_name, :start_time, :end_time

    # @note This service operates on a single model and therefore should be
    #   thread safe. However, DB connection pools are limited so concurrency
    #   should be throttled to a reasonable rate.
    #
    # @param [String] model_name The list of model names to reconcile.
    # @param [Time] start_time The earliest created_at time. Defaults to 1 week ago
    # @param [Time] end_time The latest created_at time. Defaults to Today
    def initialize(model_name, start_time = nil, end_time = nil)
      @model_name = model_name
      @start_time = start_time || (Time.now.utc - 1.week).beginning_of_day
      @end_time = end_time || Time.now.utc.end_of_day
    end

    def call
      model = get_class(model_name)
      return unless model.respond_to?(:dp_observable?)
      report_historical_data(model)
    end

    # Reports out the record attributes for the provided dates
    # @param [ActiveRecord::Base] model The ActiveRecord class/model
    def report_historical_data(model)
      models = model.where(created_at: start_time...end_time)

      if models.count.zero?
        errors.push(ArgumentError.new("no #{model_name} records for #{start_time} to #{end_time}"))
      else
        DataProducer.logger.debug("Publishing #{models.count} #{model_name} records...")
        report(models)
      end
    end

    def report(models)
      models.find_each do |record|
        name = record.class.name
        attributes = record.attributes
        ReportingService.call(:create, name, attributes)
      end
    end

    # Safe conversion of string to class
    def get_class(name)
      Kernel.const_get(name)
    rescue NameError
      nil
    end
  end
end
