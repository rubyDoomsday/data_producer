# frozen_string_literal: true

dp = OpenStruct.new(Rails.configuration.data_producer)

DataProducer.configure do |c|
  c.deliver = dp.deliver
  c.logger = Rails.logger
  c.keep_alive = dp.keep_alive
  c.heartbeat = dp.heartbeat
  c.client_id = dp.client_id

  c.aws_access_key_id = dp.aws_access_key_id
  c.aws_secret_access_key = dp.aws_secret_access_key
  c.aws_region = dp.aws_region
  c.kinesis_host = dp.kinesis_host
end

DataProducer.start
