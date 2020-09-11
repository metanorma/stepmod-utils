require 'spec_helper'

require 'stepmod/utils/smrl_description_converter'

RSpec.describe Stepmod::Utils::SmrlDescriptionConverter do
  let(:schema) { 'schema' }

  it 'takes ext_description linkend attribute' do
    input = node_for(
      <<~XML
        <ext_descriptions>
          <ext_description linkend='#{schema}'></ext_description>
        </ext_descriptions>
      XML
    )
    expect(described_class.convert(input)).to include(%{(*"#{schema}"})
  end

  it 'converts html children' do
    input = node_for(
      <<~XML
        <ext_descriptions>
          <ext_description linkend='#{schema}'><li>foo</li></ext_description>
        </ext_descriptions>
      XML
    )
    expect(described_class.convert(input)).to include("foo\n")
  end
end
