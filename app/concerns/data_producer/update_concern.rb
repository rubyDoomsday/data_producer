# frozen_string_literal: true

module DataProducer
  # UpdateConcern provides a logical separation for :update action workflows
  # @author rebecca.chapin@fundthatflip.com
  #
  # @private
  #
  # @example
  #   include UpdateConcern
  module UpdateConcern
    extend ActiveSupport::Concern

    included do
      after_update :push_update

      include DataProducer::SharedConcern
    end

    # Traps changes after a record is destroyed.
    def push_update
      return unless DataProducer.report?

      name = self.class.name
      ReportingService.call(:update, name, attributes)
    end
  end
end
