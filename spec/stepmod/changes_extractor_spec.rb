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

    describe "#call" do
      let(:change_collection) { subject.call }

      it "should create the collection from fixture files" do
        expect(change_collection.count).to eq(31)
      end
    end

    describe "#add_module_changes_to_collection" do
      before do
        add_module_changes_to_collection
      end

      let(:add_module_changes_to_collection) do
        subject.send(
          :add_module_changes_to_collection,
          xml_data,
          change_collection,
          schema_name,
        )
      end

      let(:change_collection) do
        Stepmod::Utils::ChangeCollection.new(
          stepmod_dir: fixtures_path("stepmod_terms_mock_directory"),
        )
      end

      let(:xml_data) do
        xml = <<~XML
          <changes>
            <change version="2">
               <description>The scope statement has been amended in order to clarify the appropriate use of this module.</description>
            </change>
            <change version="3">
               <mapping.changes>
                  <mapping.change>ENTITY Description_text_assignment</mapping.change>
                  <mapping.change>ENTITY Description_text</mapping.change>
               </mapping.changes>
            </change>
            <change version="4">
               <arm.changes>
                  <arm.additions>
                     <modified.object type="ENTITY" name="description_text_assignment_relationship"/>
                  </arm.additions>
               </arm.changes>
               <mim.changes>
                  <mim.additions>
                    <modified.object type="USE_FROM"
                                     name="systems_engineering_representation_schema"
                                     interfaced.items="description_text_assignment_relationship"/>
                    <modified.object type="ENTITY" name="applied_description_text_assignment_relationship"/>
                  </mim.additions>
               </mim.changes>
            </change>
          </changes>
        XML

        Nokogiri::XML(xml).root
      end

      let(:schema_name) { "test_schema" }

      it "should add mapping changes to version 3 change editions" do
        change_edition = change_collection.fetch(schema_name, "arm")
                                          .change_editions["3"]
        mapping = [
          { "change" => "ENTITY Description_text_assignment" },
          { "change" => "ENTITY Description_text" },
        ]

        expect(change_edition.mapping).to eq(mapping)
      end

      it "should add description to all version 2 changes" do
        description = "The scope statement has been amended in order to " \
                      "clarify the appropriate use of this module."

        change_collection.each do |change|
          change_edition = change.fetch_change_edition("2")

          expect(change_edition.description).to eq(description)
        end
      end
    end

    describe "#extract_mapping_changes" do
      let(:extract_mapping_changes) do
        subject.send(:extract_mapping_changes, change_node)
      end

      context "mapping changes with multiple changes" do
        let(:change_node) do
          change_node = <<~CHANGE_NODE
            <change version="3">
              <mapping.changes>
                <mapping.change>ENTITY Description_text_assignment</mapping.change>
                <mapping.change>ENTITY Description_text</mapping.change>
              </mapping.changes>
            </change>
          CHANGE_NODE

          Nokogiri::XML(change_node).root
        end

        let(:expected_output) do
          [
            { "change" => "ENTITY Description_text_assignment" },
            { "change" => "ENTITY Description_text" },
          ]
        end

        it { expect(extract_mapping_changes).to eq(expected_output) }
      end

      context "mapping changes with only description" do
        let(:change_node) do
          change_node = <<~CHANGE_NODE
            <change version="3">
              <mapping.changes>
                <description>Change occurrences of pdm_ to design_pdm_ to correct mistakes in previous mappings.</description>
              </mapping.changes>
            </change>
          CHANGE_NODE

          Nokogiri::XML(change_node).root
        end

        let(:expected_output) do
          [
            { "description" => "Change occurrences of pdm_ to design_pdm_ to correct mistakes in previous mappings." },
          ]
        end

        it { expect(extract_mapping_changes).to eq(expected_output) }
      end
    end

    describe "#extract_modified_objects" do
      let(:extract_modified_objects) do
        subject.send(:extract_modified_objects, modified_objects)
      end

      context "when `modified.objects` do not have a description" do
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
              <modified.object type="TYPE" name="role_select" />
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

      context "when `modified.objects` have a description" do
        let(:modified_objects) do
          modification_nodes = <<~MODIFICATION_NODES
            <schema.modifications>
              <modified.object type="ENTITY" name="curve_bounded_surface">
                 <description>WHERE 'WR4' expression changed</description>
              </modified.object>
              <modified.object type="ENTITY" name="locally_refined_spline_curve">
                 <description>Add WHERE 'WR3'</description>
              </modified.object>
            </schema.modifications>
          MODIFICATION_NODES

          [Nokogiri::XML(modification_nodes).root]
        end

        let(:expected_output) do
          [
            {
              type: "ENTITY",
              name: "curve_bounded_surface",
              description: "WHERE 'WR4' expression changed",
            },
            {
              type: "ENTITY",
              name: "locally_refined_spline_curve",
              description: "Add WHERE 'WR3'",
            },
          ]
        end

        it "should extract correct modified.objects data" do
          expect(extract_modified_objects).to eq(expected_output)
        end
      end

      context "when `modified.objects` have a interfaced.item" do
        let(:modified_objects) do
          deletion_nodes = <<~DELETION_NODES
            <schema.deletions>
              <modified.object name="measure_schema"
                               type="REFERENCE_FROM"
                               interfaced.items="length_measure"/>
              <modified.object name="edge_with_length" type="ENTITY"/>
            </schema.deletions>
          DELETION_NODES

          [Nokogiri::XML(deletion_nodes).root]
        end

        let(:expected_output) do
          [
            {
              type: "REFERENCE_FROM",
              name: "measure_schema",
              interfaced_items: "length_measure",
            },
            {
              type: "ENTITY",
              name: "edge_with_length",
            },
          ]
        end

        it "should extract correct modified.objects data" do
          expect(extract_modified_objects).to eq(expected_output)
        end
      end
    end
  end
end
