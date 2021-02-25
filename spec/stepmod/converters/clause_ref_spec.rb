# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stepmod::Utils::Converters::ClauseRef do
  subject(:convert) { cleaned_adoc(described_class.new.convert(node_for(input_xml))) }

  let(:input_xml) do
    '<clause_ref linkend="definition: individual   activity ">individual activity</clause_ref>'
  end
  let(:output) do
    ' term:[individual activity] '
  end

  it 'compacts and removes any whitespace' do
    expect(convert).to eq(output)
  end
end
