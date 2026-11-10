require "spec_helper"
require "stepmod/utils/schema_change"

RSpec.describe Stepmod::Utils::SchemaChange do
  describe "#to_h" do
    it "returns string keys for all given attributes" do
      change = described_class.new(
        type: "ENTITY", name: "Foo", description: "d", interfaced_items: "a,b",
      )

      expect(change.to_h).to eq(
        "type" => "ENTITY", "name" => "Foo",
        "description" => "d", "interfaced_items" => "a,b"
      )
    end

    it "omits attributes that are nil" do
      change = described_class.new(type: "TYPE", name: "Foo")

      expect(change.to_h).to eq("type" => "TYPE", "name" => "Foo")
    end
  end
end
