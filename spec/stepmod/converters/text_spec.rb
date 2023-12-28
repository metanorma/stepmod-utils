# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::Text do
  let(:converter) { described_class.new }

  context "outside equation" do
    let(:input_xml) { "Hello world" }
    let(:output) { "Hello world" }

    it "converts text correctly" do
      input = node_for(input_xml)
      expect(converter.convert(input).strip).to eq(output.strip)
    end
  end

  context "inside equation" do
    let(:eqn_converter) { Stepmod::Utils::Converters::Eqn.new }

    let(:input_xml) do
      <<~XML
        <eqn id="eqnGM1">
          <i>
            &#x3C7;
            <b>My node</b>
            <sub>ms</sub>
            <i>Italic text</i>
            =
            <b><i>V - E + 2F - L</i></b>
            <sub>l</sub>
            <b> - 2(S - G</b>
            <sup>s</sup>)
          </i>
          = 0 &#x2003; (1) &#x2003;
        </eqn>
      XML
    end

    let(:output) do
      <<~XML
        [[eqnGM1]]

        [stem]
        ++++
        χ (My node)_{ms}(Italic text) = V - E + 2F - L_{l} - 2(S - G^{s})  = 0
        ++++


      XML
    end

    it "converts text correctly" do
      input = node_for(input_xml)
      expect(eqn_converter.convert(input).strip).to eq(output.strip)
    end
  end
end
