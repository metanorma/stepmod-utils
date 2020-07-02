# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stepmod::Utils::Converters::ClauseRef do
  let(:converter) { described_class.new }
  let(:xml_input) do
    '<clause_ref linkend="definition: individual   activity ">individual activity</clause_ref>'
  end
  let(:output) do
    ' term:[individual activity] '
  end

  it 'compacts and removes any whitespace' do
    input = node_for(xml_input)
    expect(converter.convert(input)).to match(output)
  end
end
