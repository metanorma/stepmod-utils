# frozen_string_literal: true

require 'spec_helper'
require 'stepmod/utils/converters/schema_diag'
require 'stepmod/utils/converters/express_g'

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
      [.svgmap]
      ====
      image::basic_attribute_schemaexpg1.svg[]

      * <<express:support_resource_schema,support_resource_schema>>; ../../resources/support_resource_schema/support_resource_schema.xml
      * <<express:basic_attribute_schema,basic_attribute_schema>>; ../../resources/basic_attribute_schema/basic_attribute_schema.xml
      ====
    XML
  end

  it 'converts html children' do
    input = node_for(input_xml)
    expect(converter.convert(input)).to eq(output.strip)
  end
end
