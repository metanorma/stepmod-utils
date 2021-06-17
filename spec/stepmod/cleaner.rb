require "spec_helper"
require "stepmod/utils/converters/ext_description"
require "stepmod/utils/cleaner"

RSpec.describe Stepmod::Utils::Cleaner do
  subject(:converter) { Stepmod::Utils::Converters::ExtDescription.new }
  subject(:cleaner) { described_class.new }

  context "when text whitespace is present" do
    let(:input_xml) do
      <<~TEXT
        <ext_description linkend="management_resources_schema.action_method_role">
            <p>An <b>action_method_role</b> is a definition of a role for an
          <express_ref linkend="management_resources_schema:ir_express:action_schema.action_method"/>
          and a description of that role.
        </p>
          <example>'Process XYZ' is an
          <express_ref linkend="action_schema:ir_express:action_schema.action_method"/>.
          An
          <express_ref linkend="management_resources_schema:ir_express:management_resources_schema.action_method_assignment"/>
          assigns the
          <express_ref linkend="action_schema:ir_express:action_schema.action_method"/>
          to the definition of a specific mechanical part. </example>
          The <b>action_method_role</b> for the
          <express_ref linkend="management_resources_schema:ir_express:management_resources_schema.action_method_assignment"/>
          is 'Process to mill mechanical part'.

        </ext_description>
      TEXT
    end
    let(:output) do
      <<~TEXT
        (*"management_resources_schema.action_method_role"
        An *action\\_method\\_role* is a definition of a role for an *action_method* and a description of that role.

        [example]
        ====
        'Process XYZ' is an *action_method*. An *action_method_assignment* assigns the *action_method* to the definition of a specific mechanical part.
        ====

        The *action\\_method\\_role* for the *action_method_assignment* is 'Process to mill mechanical part'.
        *)
      TEXT
    end

    it "strips all whitespace at the begining of lines" do
      input = node_for(input_xml)
      expect(cleaner.tidy(converter.convert(input))).to eq(output)
    end
  end
end
