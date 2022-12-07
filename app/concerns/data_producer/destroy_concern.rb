# frozen_string_literal: true

module DataProducer
  # DestroyConcern provides a logical separation for :destroy action workflows
  # @author rebecca.chapin@fundthatflip.com
  #
  # @private
  #
  # @example
  #   include DestroyConcern
  module DestroyConcern
    extend ActiveSupport::Concern

    included do
      after_destroy :push_destroy

      include DataProducer::SharedConcern
    end

    # Traps changes after a record is destroyed.
    def push_destroy
      return unless DataProducer.report?

      name = self.class.name
      ReportingService.call(:destroy, name, attributes)
    end
  end
end
