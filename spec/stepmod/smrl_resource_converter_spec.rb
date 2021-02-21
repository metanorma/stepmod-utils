require 'spec_helper'

require 'stepmod/utils/smrl_resource_converter'

RSpec.describe Stepmod::Utils::SmrlResourceConverter do
  let(:input_xml) do
    <<~XML
      <resource>
        <schema name="contract_schema" number="8369" version="3">
          <introduction>
            The subject of the <b>contract_schema</b> is the description of contract agreements.
          </introduction>
          <fund_cons>
            Contract information may be attached to any aspect of a product data.
          </fund_cons>
          <express-g>
            <imgfile file="#{fixtures_path('basic_attribute_schemaexpg1.xml')}"/>
            <imgfile file="#{fixtures_path('basic_attribute_schemaexpg2.xml')}"/>
          </express-g>
        </schema>
      </resource>
    XML
  end

  let(:output) do
    <<~ADOC
      (*"contract_schema"
      == Introduction

      The subject of the *contract_schema* is the description of contract agreements.

      == Fundamental concerns

      Contract information may be attached to any aspect of a product data.

      [.svgmap]
      ====
      image::basic_attribute_schemaexpg1.svg[]

      * <<express:support_resource_schema>>; 1
      * <<express:basic_attribute_schema>>; 2
      ====

      [.svgmap]
      ====
      image::basic_attribute_schemaexpg2.svg[]

      * <<express:custom.name>>; 1
      * <<express:custom2.name2>>; 2
      ====
      *)
    ADOC
  end

  it 'Converts input file into the correct adoc' do
    expect(described_class.convert(input_xml)).to eq(output)
  end

  context 'when dl tags present' do
    let(:input_xml) do
      <<~XML
        <resource>
          <schema name="contract_schema" number="8369" version="3">
            <dl>
              <dt>one</dt>
              <dd>this is one</dd>
              <dt>two</dt>
              <dd>this is two</dd>
              <dt>
              </dl> </dt>
              <dd>This is blank</dd>
          </schema>
        </resource>
      XML
    end
    let(:output) do
      <<~XML
        (*"contract_schema"
        one:: this is one
        two:: this is two
        {blank}:: This is blank
        *)
      XML
    end

    it 'renders correclt internal dl tags and children' do
      expect(described_class.convert(input_xml)).to eq(output)
    end
  end
end
