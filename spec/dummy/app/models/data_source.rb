# frozen_string_literal: true

class DataSource < ObservableRecord
  module Types
    ALL = [
      "a source_type",
      "another source_type",
      "best source_type",
    ].freeze
  end

  enum status_code: {
    zero: 0,
    one: 1,
    two: 2,
    three: 3,
    four: 4,
    five: 5,
  }

  validates :title, presence: true
  validates :source_type,
    presence: true,
    inclusion: {in: DataSource::Types::ALL}
  validates :summary,
    presence: true,
    length: {minimum: 3, maximum: 500}

  def self.source_types
    DataSource::Types::ALL
  end
end
