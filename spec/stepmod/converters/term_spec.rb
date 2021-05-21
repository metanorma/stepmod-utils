# frozen_string_literal: true

require 'spec_helper'
require 'support/smrl_converters_setup'

RSpec.describe Stepmod::Utils::Converters::Term do
  let(:converter) { described_class.new }
  let(:xml_input) do
    '<term id="ap233_function">function; transformation</term>'
  end
  let(:output) do
    "=== function\n\nalt:[transformation]"
  end

  it 'converts seimicolon text as al' do
    input = node_for(xml_input)
    expect(converter.convert(input).strip).to eq(output.strip)
  end
end
