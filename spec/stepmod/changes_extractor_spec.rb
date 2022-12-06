require "spec_helper"
require "stepmod/utils/changes_extractor"

RSpec.describe Stepmod::Utils::ChangesExtractor do
  describe "Instance methods" do
    subject do
      described_class.new(
        stepmod_dir: fixtures_path("stepmod_terms_mock_directory"),
        stdout: StringIO.new,
      )
    end

    describe "#extract_modified_objects" do
      let(:extract_modified_objects) do
        subject.send(:extract_modified_objects, modified_objects)
      end

      let(:modified_objects) do
        addition_nodes = <<~ADDITION_NODES
          <schema.additions>
            <modified.object type="ENTITY" name="description_attribute"/>
            <modified.object type="TYPE" name="description_attribute_select"/>
            <modified.object type="FUNCTION" name="get_description_value"/>
            <modified.object type="FUNCTION" name="get_id_value"/>
            <modified.object type="FUNCTION" name="get_name_value"/>
            <modified.object type="FUNCTION" name="get_role"/>
            <modified.object type="ENTITY" name="id_attribute"/>
            <modified.object type="TYPE" name="id_attribute_select"/>
            <modified.object type="ENTITY" name="name_attribute"/>
            <modified.object type="TYPE" name="name_attribute_select"/>
            <modified.object type="ENTITY" name="object_role"/>
            <modified.object type="ENTITY" name="role_association"/>
            <modified.object type="TYPE" name="role_select"/>
          </schema.additions>
        ADDITION_NODES

        [Nokogiri::XML(addition_nodes).root]
      end

      let(:expected_output) do
        [
          { type: "ENTITY", name: "description_attribute" },
          { type: "TYPE", name: "description_attribute_select" },
          { type: "FUNCTION", name: "get_description_value" },
          { type: "FUNCTION", name: "get_id_value" },
          { type: "FUNCTION", name: "get_name_value" },
          { type: "FUNCTION", name: "get_role" },
          { type: "ENTITY", name: "id_attribute" },
          { type: "TYPE", name: "id_attribute_select" },
          { type: "ENTITY", name: "name_attribute" },
          { type: "TYPE", name: "name_attribute_select" },
          { type: "ENTITY", name: "object_role" },
          { type: "ENTITY", name: "role_association" },
          { type: "TYPE", name: "role_select" },
        ]
      end

      it "should extract correct modified.objects data" do
        expect(extract_modified_objects).to eq(expected_output)
      end
    end
  end
end
