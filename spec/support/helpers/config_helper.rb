# frozen_string_literal: true

module ConfigHelper
  def self.reset
    DataProducer.instance_variable_set("@config", nil)
  end
end
