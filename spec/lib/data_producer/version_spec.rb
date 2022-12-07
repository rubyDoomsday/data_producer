# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataProducer do
  it "has factory_bot setup" do
    check = build(:version)
    expect(check[:version]).to be_truthy
  end

  it "has semantic versioning" do
    expect(DataProducer.version).to_not eq nil
  end
end
