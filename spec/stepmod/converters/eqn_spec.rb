# frozen_string_literal: true

require 'spec_helper'
require 'stepmod/utils/converters/eqn'

RSpec.describe Stepmod::Utils::Converters::Eqn do
  let(:converter) { described_class.new }
  let(:xml_input) do
    <<~TEXT
      <eqn id="eqnGM1">
        <i>
          &#x3C7;
          <sub>ms</sub>
          =
          <b>V - E + 2F - L</b>
          <sub>l</sub>
          <b> - 2(S - G</b>
          <sup>s</sup>)
        </i>
        = 0 &#x2003; (1) &#x2003;
      </eqn>
    TEXT
  end
  let(:output) do
    "[stem]\n++++\n _χ ~ms~ = *V - E + 2F - L*~l~ *- 2(S - G*^s^)_  = 0   (1)   \n++++\n"
  end

  it 'converts complex children block by rules' do
    input = node_for(xml_input)
    expect(converter.convert(input)).to eq(output)
  end
end
