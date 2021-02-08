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

      * <<express:custom.name,custom>>; ../../resources/custom/custom.xml#custom.name
      * <<express:custom2.name2,custom2>>; ../../resources/custom2/custom2.xml#custom2.name2
      ====


      [.svgmap]
      ====
      image::action_and_model_relationships_schemaexpg1.svg[]

      * <<express:product_and_model_relationships_schema,product_and_model_relationships_schema>>; ../../resources/product_and_model_relationships_schema/product_and_model_relationships_schema.xml#product_and_model_relationships_schema
      * <<express:action_and_model_relationships_schema,action_and_model_relationships_schema>>; ../../resources/action_and_model_relationships_schema/action_and_model_relationships_schema.xml#action_and_model_relationships_schema
      * <<express:state_and_model_relationships_schema,state_and_model_relationships_schema>>; ../../resources/state_and_model_relationships_schema/state_and_model_relationships_schema.xml#state_and_model_relationships_schema
      * <<express:property_distribution_and_model_relationships_schema,property_distribution_and_model_relationships_schema>>; ../../resources/property_distribution_and_model_relationships_schema/property_distribution_and_model_relationships_schema.xml#property_distribution_and_model_relationships_schema
      * <<express:product_definition_schema,product_definition_schema>>; ../../resources/product_definition_schema/product_definition_schema.xml#product_definition_schema
      * <<express:structural_response_representation_schema,structural_response_representation_schema>>; ../../resources/structural_response_representation_schema/structural_response_representation_schema.xml#structural_response_representation_schema
      * <<express:product_analysis_schema,product_analysis_schema>>; ../../resources/product_analysis_schema/product_analysis_schema.xml#product_analysis_schema
      * <<express:analysis_schema,analysis_schema>>; ../../resources/analysis_schema/analysis_schema.xml#analysis_schema
      * <<express:support_resource_schema,support_resource_schema>>; ../../resources/support_resource_schema/support_resource_schema.xml#support_resource_schema
      * <<express:action_schema,action_schema>>; ../../resources/action_schema/action_schema.xml#action_schema
      * <<express:finite_element_analysis_control_and_result_schema,finite_element_analysis_control_and_result_schema>>; ../../resources/finite_element_analysis_control_and_result_schema/finite_element_analysis_control_and_result_schema.xml#finite_element_analysis_control_and_result_schema
      * <<express:state_type_schema,state_type_schema>>; ../../resources/state_type_schema/state_type_schema.xml#state_type_schema
      * <<express:product_property_definition_schema,product_property_definition_schema>>; ../../resources/product_property_definition_schema/product_property_definition_schema.xml#product_property_definition_schema
      * <<express:fea_definition_relationships_schema,fea_definition_relationships_schema>>; ../../resources/fea_definition_relationships_schema/fea_definition_relationships_schema.xml#fea_definition_relationships_schema
      * <<express:topology_schema,topology_schema>>; ../../resources/topology_schema/topology_schema.xml#topology_schema
      ====

    ADOC
  end

  it 'takes ext_description linkend attribute' do
    input = node_for(input_xml)
    expect(converter.convert(input)).to eq(adoc_output)
  end
end
