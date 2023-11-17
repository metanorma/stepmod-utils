# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"
require "stepmod/utils/converters/eqn"

RSpec.describe Stepmod::Utils::Converters::Em do
  subject(:convert) do
    cleaned_adoc(described_class.new.convert(node_for(input_xml)))
  end

  context "when there is an equation inside strong tag" do
    context "with id" do
      let(:input_xml) do
        <<~XML
          <i>
            <eqn id="eqnGM1">
              &#x3C7;
              <b>My node</b>
              <sub>ms</sub> =
              <b>V - E + 2F - L</b>
              <sub>l</sub>
              <b> - 2(S - G</b>
              <sup>s</sup>)
              = 0 &#x2003; (1) &#x2003;
            </eqn>
          </i>
        XML
      end

      let(:output) do
        <<~XML
          [[eqnGM1]]

          [stem]
          ++++
          χ My node_{ms} = V - E + 2F - L_{l} - 2(S - G^{s}) = 0
          ++++

        XML
      end

      it "does not add underscores around the eqation block" do
        expect(convert).to eq(output)
      end
    end

    context "without id" do
      let(:input_xml) do
        <<~XML
          <i>
            <eqn>
              &#x3C7;
              <b>My node</b>
              <sub>ms</sub>
              =
              <b>V - E + 2F - L</b>
              <sub>l</sub>
              <b> - 2(S - G</b>
              <sup>s</sup>)
              = 0 &#x2003; (1) &#x2003;
            </eqn>
          </i>
        XML
      end

      let(:output) do
        <<~XML

          [stem]
          ++++
          χ My node_{ms} = V - E + 2F - L_{l} - 2(S - G^{s}) = 0
          ++++

        XML
      end

      it "does not add underscores around the eqation block" do
        expect(convert).to eq(output)
      end
    end
  end

  context "when there is no equation inside strong tag" do
    context "" do
      let(:input_xml) do
        <<~XML
          <i>Some text that needs to be bold</i>
        XML
      end

      let(:output) do
        <<~OUTPUT.strip
          _Some text that needs to be bold_
        OUTPUT
      end

      it "add asterisks around the eqation block" do
        expect(convert).to eq(output)
      end
    end
  end
end
