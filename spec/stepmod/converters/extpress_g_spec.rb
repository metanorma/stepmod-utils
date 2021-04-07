# frozen_string_literal: true

require 'spec_helper'

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

      *)

      (*"test_schema.__expressg"
      [.svgmap]
      ====
      image::basic_attribute_schemaexpg1.svg[]

      * <<express:support_resource_schema>>; 1
      * <<express:basic_attribute_schema>>; 2
      ====


      *)

      (*"test_schema.__expressg"
      [.svgmap]
      ====
      image::basic_attribute_schemaexpg2.svg[]

      * <<express:custom.name>>; 1
      * <<express:custom2.name2>>; 2
      ====


      *)

      (*"test_schema.__expressg"
      [.svgmap]
      ====
      image::action_and_model_relationships_schemaexpg1.svg[]

      * <<express:product_and_model_relationships_schema>>; 1
      * <<express:action_and_model_relationships_schema>>; 2
      * <<express:state_and_model_relationships_schema>>; 3
      * <<express:property_distribution_and_model_relationships_schema>>; 4
      * <<express:product_definition_schema>>; 5
      * <<express:structural_response_representation_schema>>; 6
      * <<express:product_analysis_schema>>; 7
      * <<express:analysis_schema>>; 8
      * <<express:support_resource_schema>>; 9
      * <<express:action_schema>>; 10
      * <<express:finite_element_analysis_control_and_result_schema>>; 11
      * <<express:state_type_schema>>; 12
      * <<express:product_property_definition_schema>>; 13
      * <<express:fea_definition_relationships_schema>>; 14
      * <<express:topology_schema>>; 15
      ====

    ADOC
  end

  it 'takes ext_description linkend attribute' do
    input = node_for(input_xml)
    expect(converter.convert(input, { schema_name: 'test_schema' })).to eq(adoc_output)
  end
end
