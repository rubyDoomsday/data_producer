# frozen_string_literal: true

module DataProducer
  # ApplicationServices are designed to encapsulate and respond to all
  # downstream errors. This ensures implementation details don't leak to the
  # host application. This is accomplished but rescuing/capturing any resulting
  # errors and reporting them out via the @errors array. The success/failure of
  # a service's abilty to complete its programed task is upltimately validated
  # using #success? or #failure checks.
  # @author rebecca.chapin@fundthatflip.com
  class ApplicationService
    private_class_method :new

    # Call is the expected interface for an ApplicationService it accepts a block
    # and will yield the service to permit nesting multiple services.
    #
    # @param [Hash] args The named arguments defined by the child class initializer
    # @yield [ApplicationService] The application service
    # @return [Object] The result
    #
    # @example
    #   SomeService.call(foo: "bar").do |service|
    #     return if service.failed?
    #     AnotherService.call(result: service.result)
    #   end
    def self.call(*args)
      service = new(*args)
      service.send(:call)
      if block_given?
        yield service
      else
        service.result
      end
    end

    # @return [Boolean] True if no errors present
    def success?
      errors.empty?
    end

    # @return [Boolean] True if errors present
    def failed?
      !success?
    end

    # @return [Object] The result of the service completed
    def result
      @result ||= nil
    end

    # @return [Array] List of errors reported out by the service
    def errors
      @errors ||= []
    end

    private

    attr_writer :result

    # Call is provided as an interface for the child class to override
    # @note Call should not return any object use inspect #result instead
    def call
      # NOOP
    end
  end
end
