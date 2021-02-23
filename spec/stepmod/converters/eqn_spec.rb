# frozen_string_literal: true

require 'spec_helper'
require 'stepmod/utils/converters/eqn'

RSpec.describe Stepmod::Utils::Converters::Eqn do
  subject(:converter) { described_class.new }

  let(:xml_input) do
    <<~XML
      <eqn id="eqnGM1">
        <i>
          &#x3C7;
          <b><i>My node</i></b>
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
    "[[eqnGM1]]\n\n[stem]\n++++\nχ My node ms Italic text = V - E + 2F - L l - 2(S - G s) = 0\n++++\n\n"
  end

  it 'converts complex children block by rules' do
    input = node_for(xml_input)
    expect(converter.convert(input)).to eq(output)
  end

  context 'when special symbols are used' do
    let(:xml_input) do
      <<~XML
        <eqn id="eqnGM1"> <i> &#967; <sub>ms</sub> = <b>V - E + 2F - L</b> <sub>l</sub> <b> - 2(S - G</b> <sup>s</sup>) </i> = 0 &#8195; (1) &#8195; </eqn>
      XML
    end
    let(:output) do
      "[[eqnGM1]]\n\n[stem]\n++++\nχ ms = V - E + 2F - L l - 2(S - G s) = 0\n++++\n\n"
    end

    it 'converts special symbols in element' do
      input = node_for(xml_input)
      expect(converter.convert(input)).to eq(output)
    end
  end

  context 'when eqn is actually a definition list' do
    let(:xml_input) do
      <<~XML
        <eqn> <b>directrix</b> : a circle in 3D space of radius R <sub>1</sub> , </eqn>
      XML
    end
    let(:output) do
      "directrix::   a circle in 3D space of radius R ~1~ , "
    end

    it 'converts special symbols in element' do
      input = node_for(xml_input)
      expect(converter.convert(input)).to eq(output)
    end
  end

  context 'when underscore variable is used' do
    let(:xml_input) do
      <<~XML
        <eqn> <i> K1 </i>= <b>upper_index_on_u_control_points</b> </eqn>
      XML
    end
    let(:output) do
      "\n[stem]\n++++\nK1 = \"upper_index_on_u_control_points\"\n++++\n\n"
    end

    it 'converts special symbols in element' do
      input = node_for(xml_input)
      expect(converter.convert(input)).to eq(output)
    end
  end
end
