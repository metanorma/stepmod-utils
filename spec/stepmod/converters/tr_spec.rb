require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::Tr do
  subject(:converter) { described_class.new }

  describe "#convert" do
    context "when tr contains header cells" do
      let(:xml_input) do
        <<~XML
          <tr>
            <th>Header 1</th>
            <th>Header 2</th>
          </tr>
        XML
      end

      let(:output) do
        "| Header 1 | Header 2\n\n"
      end

      it "converts header row correctly" do
        expect(converter.convert(node_for(xml_input))).to eq(output)
      end
    end

    context "when tr contains data cells" do
      let(:xml_input) do
        <<~XML
          <tr>
            <td>Data 1</td>
            <td>Data 2</td>
          </tr>
        XML
      end

      let(:output) do
        "| Data 1 | Data 2\n\n"
      end

      it "converts data row correctly" do
        expect(converter.convert(node_for(xml_input))).to eq(output)
      end
    end
  end
end
