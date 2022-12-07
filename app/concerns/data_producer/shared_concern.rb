# frozen_string_literal: true

module DataProducer
  # SharedConcern provides a ability for shared concerns
  # @author rebecca.chapin@fundthatflip.com
  #
  # @private
  #
  # @example
  #   include SharedConcern
  module SharedConcern
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    module ClassMethods
      def dp_observable?
        true
      end
    end
  end
end
