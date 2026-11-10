require "spec_helper"
require "stepmod/utils/mapping_change"

RSpec.describe Stepmod::Utils::MappingChange do
  describe "#to_h" do
    it "returns a string-keyed hash with only the change" do
      change = described_class.new(change: "Renamed")

      expect(change.to_h).to eq("change" => "Renamed")
    end

    it "returns a string-keyed hash with only the description" do
      change = described_class.new(description: "Notes")

      expect(change.to_h).to eq("description" => "Notes")
    end
  end
end
