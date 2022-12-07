# frozen_string_literal: true

module DataProducer
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
