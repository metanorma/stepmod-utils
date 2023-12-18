# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::A do
  let(:converter) { described_class.new }

  context "format with number" do
    describe "<a href=\"#eqn7\">(71)</a>" do
      let(:xml_input) do
        '<a href="#eqn7">(71)</a>'
      end

      let(:output) do
        "<<eqn7>>"
      end

      it { expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip) }
    end

    describe "<a href=\"#fig1\">Figure (1)</a>" do
      let(:xml_input) do
        '<a href="#fig1">Figure (1)</a>'
      end

      let(:output) do
        "<<fig1>>"
      end

      it { expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip) }
    end

    describe "<a href=\"#table1\">Table (1)</a>" do
      let(:xml_input) do
        '<a href="#table1">Table 1</a>'
      end

      let(:output) do
        "<<table1>>"
      end

      it { expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip) }
    end

    describe "<a href=\"6_schema.xml#eqnGM1\">(1)</a>" do
      let(:xml_input) do
        '<a href="6_schema.xml#eqnGM1">(1)</a>'
      end

      let(:output) do
        "link:6_schema.xml#eqnGM1"
      end

      it { expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip) }
    end
  end

  context "format without number" do
    describe "<a href=\"#eqn7\">This Equation</a>" do
      let(:xml_input) do
        '<a href="#eqn7">This Equation</a>'
      end

      let(:output) do
        "<<eqn7,This Equation>>"
      end

      it { expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip) }
    end

    describe "<a href=\"6_schema.xml#eqnGM1\">That Equation</a>" do
      let(:xml_input) do
        '<a href="6_schema.xml#eqnGM1">That Equation</a>'
      end

      let(:output) do
        "link:6_schema.xml#eqnGM1[That Equation]"
      end

      it { expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip) }
    end
  end
end
