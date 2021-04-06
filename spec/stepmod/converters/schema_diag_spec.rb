# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stepmod::Utils::Converters::SchemaDiag do
  let(:converter) { described_class.new }
  let(:input_xml) do
    <<~XML
      <schema_diag>
        <express-g>
          <imgfile file="#{fixtures_path('basic_attribute_schemaexpg1.xml')}"/>

        </express-g>
      </schema_diag>
    XML
  end
  let(:output) do
    <<~XML
      *)

      (*"action_schema.__expressg"
      [.svgmap]
      ====
      image::basic_attribute_schemaexpg1.svg[]

      * <<express:support_resource_schema>>; 1
      * <<express:basic_attribute_schema>>; 2
      ====
    XML
  end

  it 'converts html children' do
    input = node_for(input_xml)
    expect(converter.convert(input)).to eq(output.strip)
  end
end
