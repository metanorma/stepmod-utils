# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"
require "stepmod/utils/converters/eqn"

RSpec.describe Stepmod::Utils::Converters::Strong do
  subject(:convert) do
    cleaned_adoc(described_class.new.convert(node_for(input_xml)))
  end

  context "when there is an equation inside strong tag" do
    context "with id" do
      let(:input_xml) do
        <<~XML
          <b>
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
          </b>
        XML
      end

      let(:output) do
        <<~XML
          [[eqnGM1]]

          [stem]
          ++++
          χ bb(My node)_{ms} = bb(V - E + 2F - L)_{l}bb(- 2(S - G)^{s}) = 0
          ++++

        XML
      end

      it "does not add asterisks around the eqation block" do
        expect(convert).to eq(output)
      end
    end

    context "without id" do
      let(:input_xml) do
        <<~XML
          <b>
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
          </b>
        XML
      end

      let(:output) do
        <<~XML

          [stem]
          ++++
          χ bb(My node)_{ms} = bb(V - E + 2F - L)_{l}bb(- 2(S - G)^{s}) = 0
          ++++

        XML
      end

      it "does not add asterisks around the eqation block" do
        expect(convert).to eq(output)
      end
    end
  end

  context "when there is no equation inside strong tag" do
    context "" do
      let(:input_xml) do
        <<~XML
          <b>Some text that needs to be bold</b>
        XML
      end

      let(:output) do
        <<~OUTPUT.strip
          *Some text that needs to be bold*
        OUTPUT
      end

      it "add asterisks around the eqation block" do
        expect(convert).to eq(output)
      end
    end
  end
end
