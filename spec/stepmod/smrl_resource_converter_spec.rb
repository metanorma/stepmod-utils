require 'spec_helper'

require 'stepmod/utils/smrl_resource_converter'

RSpec.describe Stepmod::Utils::SmrlResourceConverter do
  let(:input) do
    <<~XML
      <schema name="contract_schema" number="8369" version="3">
        <introduction>
          The subject of the <b>contract_schema</b> is the description of contract agreements.
        </introduction>
        <fund_cons>
          Contract information may be attached to any aspect of a product data.
        </fund_cons>
        <express-g>
          <imgfile file="contract_schemaexpg1.xml"/>
          <imgfile file="contract_schemaexpg2.xml"/>
        </express-g>
      </schema>
    XML
  end

  let(:output) do
    "== Introduction\n\n The subject of the *contract\\_schema* is the description of contract agreements. \n\n== Fundamental concerns\n\n Contract information may be attached to any aspect of a product data. \n\nexpg_image:contract_schemaexpg1.xml[]\n\nexpg_image:contract_schemaexpg2.xml[]\n\n"
  end

  it 'Converts input file into the correct adoc' do
    expect(described_class.convert(input)).to eq(output)
  end
end
