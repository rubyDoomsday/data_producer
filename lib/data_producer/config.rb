# frozen_string_literal: true

module DataProducer
  class ConfigError < StandardError; end

  class Config # rubocop:disable Metrics/ClassLength
    attr_writer :deliver,
      :client_id,
      :logger,
      :topic,
      :keep_alive,
      :heartbeat,
      :aws_access_key_id,
      :aws_secret_access_key,
      :aws_region,
      :kinesis_host

    def initialize(opts = {}) # rubocop:disable Metrics/MethodLength
      options = validate!(opts)

      @deliver = options[:deliver]
      @keep_alive = options[:keep_alive]
      @heartbeat = options[:heartbeat]
      @topic = options[:topic]
      @logger = options[:logger]

      # kinesis specific
      @client_id = options[:client_id]
      @aws_access_key_id = options[:aws_access_key_id]
      @aws_secret_access_key = options[:aws_secret_access_key]
      @aws_region = options[:aws_region]
      @kinesis_host = options[:kinesis_host]
    end

    def deliver
      @deliver || Defaults.deliver
    end

    def client_id
      @client_id || Defaults.client_id
    end

    def logger
      @logger || Defaults.logger
    end

    def topic
      @topic || Defaults.topic
    end

    def keep_alive
      @keep_alive.nil? ? Defaults.keep_alive : @keep_alive
    end

    def heartbeat
      @heartbeat || Defaults.heartbeat
    end

    def aws_access_key_id
      @aws_access_key_id || ENV["DATA_PRODUCER_ACCESS_KEY"]
    end

    def aws_secret_access_key
      @aws_secret_access_key || ENV["DATA_PRODUCER_SERCRET_KEY"]
    end

    def aws_region
      @aws_region || Defaults.aws_region
    end

    attr_reader :kinesis_host

    def message_bus
      {
        region: aws_region,
        credentials: aws_credentials,
        endpoint: kinesis_host, # https://github.com/aws/aws-sdk-ruby/blob/ee10e00a64efa3305ec758d986830fdaaf7dc654/gems/aws-sdk-kinesis/lib/aws-sdk-kinesis/client.rb#L182
        stub_responses: !deliver, # https://github.com/aws/aws-sdk-ruby/blob/ee10e00a64efa3305ec758d986830fdaaf7dc654/gems/aws-sdk-kinesis/lib/aws-sdk-kinesis/client.rb#L290
      }.compact
    end

    private

    # @note If no credentials are explicitly provided then the default AWS credentials
    #   pipeline takes over.
    # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html#aws-ruby-sdk-setting-credentials
    def aws_credentials
      return unless aws_access_key_id && aws_secret_access_key
      @aws_credentials ||= Aws::Credentials
        .new(aws_access_key_id, aws_secret_access_key)
    end

    def validate!(opts)
      opts.map do |key, value|
        raise ConfigError, "invalid option: #{key}" unless respond_to?(key)

        validator = "validate_#{key}!"
        val = val.nil? ? send(validator, value) : nil
        [key.to_sym, val]
      end.to_h
    end

    def validate_keep_alive!(val)
      casted_value = ActiveModel::Type::Boolean.new.cast(val)
      return casted_value if [true, false].include?(casted_value)
      raise ArgumentError, "keep_alive: must be boolean"
    end

    def validate_deliver!(val)
      casted_value = ActiveModel::Type::Boolean.new.cast(val)
      return casted_value if [true, false].include?(casted_value)
      raise ArgumentError, "deliver: must be boolean"
    end

    def validate_logger!(val)
      return val if val.respond_to?(:error) && val.respond_to?(:info)
      raise ArgumentError, "invalid logger"
    end

    def validate_string!(val)
      return val if val.is_a?(String)
      raise ArgumentError, "invalid host"
    end
    alias validate_kinesis_host! validate_string!
    alias validate_aws_access_key_id! validate_string!
    alias validate_aws_secret_access_key! validate_string!
    alias validate_aws_region! validate_string!

    def validate_client_id!(val)
      return val if val.is_a?(String)
      raise ArgumentError, "invalid client id"
    end

    def validate_topic!(val)
      return val if val.is_a?(String)
      raise ArgumentError, "invalid topic"
    end

    def validate_heartbeat!(val)
      return val if val.is_a?(Integer) || val.is_a?(Float)
      raise ArgumentError, "invalid heartbeat seconds"
    end
  end
end
