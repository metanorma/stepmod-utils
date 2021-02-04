# frozen_string_literal: true

require 'spec_helper'
require 'stepmod/utils/converters/express_g'

RSpec.describe Stepmod::Utils::Converters::ExpressG do
  let(:converter) { described_class.new }
  let(:input_xml) do
    <<~XML
      <express-g>
        <imgfile file="#{fixtures_path('basic_attribute_schemaexpg1.xml')}"/>
        <imgfile file="#{fixtures_path('basic_attribute_schemaexpg2.xml')}"/>
        <imgfile file="#{fixtures_path('basic_attribute_schemaexpg3.xml')}"/>
      </express-g>
    XML
  end
  let(:adoc_output) do
    <<~ADOC

      [.svgmap]
      ====
      image::basic_attribute_schemaexpg1.svg[]

      * <<express:support_resource_schema,support_resource_schema>>; ../../resources/support_resource_schema/support_resource_schema.xml
      * <<express:basic_attribute_schema,basic_attribute_schema>>; ../../resources/basic_attribute_schema/basic_attribute_schema.xml
      ====


      [.svgmap]
      ====
      image::basic_attribute_schemaexpg2.svg[]

      * <<express:custom,custom>>; ../../resources/custom/custom.xml
      * <<express:custom2,custom2>>; ../../resources/custom2/custom2.xml
      ====


      [.svgmap]
      ====
      image::basic_attribute_schemaexpg3.svg[]

      * <<express:custom3.name1.name2>>; ../../resources/custom3/custom3.xml#custom3.name1.name2
      * <<express:custom4,custom4>>; ../../resources/custom4/custom4.xml
      ====

    ADOC
  end

  it 'takes ext_description linkend attribute' do
    input = node_for(input_xml)
    expect(converter.convert(input)).to eq(adoc_output)
  end
end
