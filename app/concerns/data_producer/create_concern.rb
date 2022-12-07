# frozen_string_literal: true

module DataProducer
  # CreateConcern provides a logical separation for :create action workflows
  # @author rebecca.chapin@fundthatflip.com
  #
  # @private
  #
  # @example
  #   include CreateConcern
  module CreateConcern
    extend ActiveSupport::Concern

    included do
      after_create :push_create

      include DataProducer::SharedConcern
    end

    # Traps changes after a record is created.
    def push_create
      return unless DataProducer.report?

      name = self.class.name
      ReportingService.call(:create, name, attributes)
    end
  end
end
