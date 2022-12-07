# frozen_string_literal: true

FactoryBot.define do
  factory :version, class: Hash do
    version { DataProducer.version }

    initialize_with { attributes }
  end
end
