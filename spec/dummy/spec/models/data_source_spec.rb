require "rails_helper"

RSpec.describe DataSource, type: :model do
  it "has a valid factory" do
    expect(create(:data_source)).to be_truthy
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:source_type) }
    it { is_expected.to validate_inclusion_of(:source_type).in_array(DataSource.source_types) }
    it { is_expected.to validate_presence_of(:summary) }
    it { is_expected.to validate_length_of(:summary).is_at_least(3) }
    it { is_expected.to validate_length_of(:summary).is_at_most(500) }

    it "validates numericality of :status_code" do
      expect { build(:data_source, status_code: -1) }.to raise_error(ArgumentError)
      expect { build(:data_source, status_code: 1_000) }.to raise_error(ArgumentError)
      expect { build(:data_source, status_code: rand(5)) }.to_not raise_error
    end

    it "exposes source_types" do
      expect(DataSource.source_types).to eq DataSource::Types::ALL
    end
  end

  context "Data Producer" do
    it "is observed by the engine" do
      expect(DataSource.dp_observable?).to eq true
    end
  end
end
