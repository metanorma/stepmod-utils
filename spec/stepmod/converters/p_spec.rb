require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::A do
  let(:converter) { described_class.new }

  context "format with number with prefix" do
    describe "<p>See Formula <a href=\"#eqn1\">(1)</a></p>" do
      let(:xml_input) do
        '<p>See Formula <a href="#eqn1">(1)</a></p>'
      end

      let(:output) do
        "See <<eqn1>>"
      end

      it { expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip) }
    end

    describe "<p>See Figure <a href=\"#fig1\">(1)</a></p>" do
      let(:xml_input) do
        '<p>See Figure <a href="#fig1">(1)</a></p>'
      end

      let(:output) do
        "See <<fig1>>"
      end

      it { expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip) }
    end

    describe "<p>See Table <a href=\"#table1\">(1)</a></p>" do
      let(:xml_input) do
        '<p>See Table <a href="#table1">(1)</a></p>'
      end

      let(:output) do
        "See <<table1>>"
      end

      it { expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip) }
    end
  end
end
