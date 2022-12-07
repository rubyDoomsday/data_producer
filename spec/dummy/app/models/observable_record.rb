# frozen_string_literal: true

class ObservableRecord < ApplicationRecord
  self.abstract_class = true

  monitor :create, :update, :destroy
end
