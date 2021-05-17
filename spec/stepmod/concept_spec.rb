require 'spec_helper'

RSpec.describe Stepmod::Utils::Concept do

  original_ext_description = ReverseAdoc::Converters.lookup(:ext_description)
  original_express_ref = ReverseAdoc::Converters.lookup(:express_ref)
  before do
    require 'stepmod/utils/converters/stepmod_ext_description'
    ReverseAdoc::Converters.register :ext_description, Stepmod::Utils::Converters::StepmodExtDescription.new
    ReverseAdoc::Converters.register :express_ref, Stepmod::Utils::Converters::ExpressRef.new
  end

  context 'when action_schema' do
    let(:input_xml) do
      <<~XML
        <ext_description linkend="action_schema.supported_item">
          The <b>supported_item</b> allows for the designation of an
          <express_ref linkend="action_schema:ir_express:action_schema.action_directive"/>,
          an
          <express_ref linkend="action_schema:ir_express:action_schema.action"/>,
          or an
          <express_ref linkend="action_schema:ir_express:action_schema.action_method"/>.
          <note>
            This specifies the use of an
            <express_ref linkend="action_schema:ir_express:action_schema.action_resource"/>.
          </note>
        </ext_description>
      XML
    end

    let(:output) do
      <<~OUTPUT
        // STEPmod path:
        === supported_item

        domain:[STEP resource]

        The *supported_item* allows for the designation of an *action_directive*, an *action*, or an *action_method*.


        NOTE: This term is incompletely defined in this document.
        Reference <<ISO_10303-41_2020>> for the complete definition.


        [.source]
        <<ISO_10303-41_2020>>

      OUTPUT
    end

    it 'correctly renders definition' do
      input = node_for(input_xml)
      expect(described_class.parse(
        input,
        reference_anchor: "ISO_10303-41_2020",
        reference_clause: nil,
        file_path: "").to_mn_adoc
      ).to eq(output)
    end


  end

  after do
    ReverseAdoc::Converters.register :ext_description, original_ext_description
    ReverseAdoc::Converters.register :express_ref, original_express_ref
  end
end

