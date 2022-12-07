FactoryBot.define do
  factory :data_source do
    title { SecureRandom.uuid }
    source_type { DataSource.source_types.sample }
    summary { LoremIpsum.generate(rand(3...500)) }
    status_code { rand(5) }

    trait :invalid do
      title { nil }
    end
  end
end
