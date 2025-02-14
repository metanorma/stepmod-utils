require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::Li do
  subject(:converter) { described_class.new }

  describe "#convert" do
    context "when li contains simple text" do
      let(:xml_input) do
        "<li>Simple list item</li>"
      end

      let(:output) do
        "Simple list item"
      end

      it "converts li element correctly" do
        expect(converter.convert(node_for(xml_input)).strip).to eq(output)
      end
    end

    context "when li contains leading whitespace" do
      let(:xml_input) do
        "<li> Indented list item</li>"
      end

      let(:output) do
        "  Indented list item\n"
      end

      it "preserves leading whitespace" do
        expect(converter.convert(node_for(xml_input))).to eq(output)
      end
    end
  end
end
