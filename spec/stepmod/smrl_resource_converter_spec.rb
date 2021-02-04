require 'spec_helper'

require 'stepmod/utils/smrl_resource_converter'

RSpec.describe Stepmod::Utils::SmrlResourceConverter do
  let(:input) do
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

      * <<express:support_resource_schema,support_resource_schema>>; ../../resources/support_resource_schema/support_resource_schema.xml
      * <<express:basic_attribute_schema,basic_attribute_schema>>; ../../resources/basic_attribute_schema/basic_attribute_schema.xml
      ====

      [.svgmap]
      ====
      image::basic_attribute_schemaexpg2.svg[]

      * <<express:custom,custom>>; ../../resources/custom/custom.xml
      * <<express:custom2,custom2>>; ../../resources/custom2/custom2.xml
      ====
      *)
    ADOC
  end

  it 'Converts input file into the correct adoc' do
    expect(described_class.convert(input)).to eq(output)
  end
end
