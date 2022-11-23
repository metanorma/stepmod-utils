require 'spec_helper'
require 'stepmod/utils/terms_extractor'
require 'stepmod/utils/converters/express_ref_express_description'

RSpec.describe Stepmod::Utils::TermsExtractor do
  subject(:call) { described_class.call(stepmod_dir, index_path, StringIO.new) }

  before do
    ReverseAdoc::Converters.unregister :express_ref
    ReverseAdoc::Converters
      .register(:express_ref,
        Stepmod::Utils::Converters::ExpressRefExpressDescription.new)
  end

  describe '.call' do
    let(:stepmod_dir) { fixtures_path('stepmod_terms_mock_directory/data') }
    let(:index_path) { fixtures_path('stepmod_terms_mock_directory/repository_index.xml') }
    let(:resource_xml_converted_definition) do
      <<~TEXT
        === agreement of common understanding

        result of discussions between the partners of product data exchange or sharing that ensures that all of them have the same understanding of the transferred or shared information
      TEXT
    end
    let(:module_xml_converted_definition) do
      <<~TEXT
        === activity

        action that has taken place, is taking place, or is expected to take place in the future
      TEXT
    end
    let(:business_object_model_converted_definition) do
      <<~TEXT
        === design phase

        period during which the engineering representation of a product is dynamic
      TEXT
    end

    let(:resource_description_hash) do
      {
        designation: "action_directive",
        domain: "resource: action_schema",
        definition: "{{entity data type}} that represents the action directive {{entity}}",
        old_definition: "An **action_directive** is an authoritative instrument that provides directions to achieve the specified results.",
      }
    end

    let(:arm_description_hash) do
      {
        designation: "Activity",
        domain: "application module: Activity_arm",
        definition: "{{entity data type}} that represents the activity {{entity}}",
        old_definition: "An **Activity** is the identification of the occurrence of an action that has taken place, is taking place, or is expected to take place in the future.",
      }
    end

    let(:mim_description_hash) do
      {
        designation: "applied_action_assignment",
        domain: "application object: Activity_mim",
        definition: "{{application object}} that is a type of {{action_assignment}} that represents the applied action assignment {{entity}}",
        old_definition: "An **applied_action_assignment** is an {{action,action}} related to the data that are affected by the {{action,action}}.",
      }
    end

    it "returns general_concepts," \
      "resource_concepts, parsed_bibliography lists" do
      expect(call.map(&:to_a).map(&:length)).to(eq([0, 0, 3, 0, 2, 1]))
    end

    it "For resources/*/descriptions.xml terms takes \
      only the first paragraph and no additonal tags " do
      ReverseAdoc::Converters.unregister :ext_description
      ReverseAdoc::Converters
        .register(:ext_description,
                  Stepmod::Utils::Converters::StepmodExtDescription.new)
      action_directive_concept = call[4][0][1]
                                 .find do |concept|
                                   concept
                                     .localizations["en"]
                                     .designations
                                     .first
                                     .designation == "action_directive"
                                 end
                                 .localizations["en"]

      expect(action_directive_concept.designations.first.designation)
        .to(eq(resource_description_hash[:designation]))
      expect(action_directive_concept.domain)
        .to(eq(resource_description_hash[:domain]))
      expect(action_directive_concept.definition.first.content)
        .to(eq(resource_description_hash[:definition]))
      expect(action_directive_concept.notes.first.content)
        .to(eq(resource_description_hash[:old_definition]))
    end

    it "For modules/*/aim_descriptions.xml terms takes only the first \
      paragraph and no additonal tags " do
      ReverseAdoc::Converters.unregister :ext_description
      ReverseAdoc::Converters
        .register(:ext_description,
                  Stepmod::Utils::Converters::StepmodExtDescription.new)
      activity_arm_concept =
        call[-1][0][1]["Activity_arm"]
        .to_a.map { |n| n.localizations["en"] }
        .find { |concept| concept.designations.first.designation == "Activity" }

      expect(activity_arm_concept.designations.first.designation)
        .to(eq(arm_description_hash[:designation]))
      expect(activity_arm_concept.definition.first.content)
        .to(eq(arm_description_hash[:definition]))
      expect(activity_arm_concept.domain)
        .to(eq(arm_description_hash[:domain]))
      expect(activity_arm_concept.notes.first.content)
        .to(eq(arm_description_hash[:old_definition]))
    end

    it "For modules/*/mim_descriptions.xml terms takes only the first \
      paragraph and no additonal tags " do
      ReverseAdoc::Converters.unregister :ext_description
      ReverseAdoc::Converters
        .register(:ext_description,
                  Stepmod::Utils::Converters::StepmodExtDescription.new)
      applied_action_assignment_concept =
        call[-1][0][2]["Activity_mim"]
        .to_a.map { |n| n.localizations["en"] }
        .find do |concept|
          concept.designations.first.designation == "applied_action_assignment"
        end

      expect(applied_action_assignment_concept.designations.first.designation)
        .to(eq(mim_description_hash[:designation]))
      expect(applied_action_assignment_concept.definition.first.content)
        .to(eq(mim_description_hash[:definition]))
      expect(applied_action_assignment_concept.domain)
        .to(eq(mim_description_hash[:domain]))
      expect(applied_action_assignment_concept.notes.first.content)
        .to(eq(mim_description_hash[:old_definition]))
    end
  end

  describe "Instance methods" do
    subject do
      described_class.new(
        fixtures_path("stepmod_terms_mock_directory"),
        fixtures_path("stepmod_terms_mock_directory/repository_index.xml"),
        StringIO.new,
      )
    end

    describe "#generate_entity_definition" do
      let(:generate_entity_definition) do
        subject.send(:generate_entity_definition, entity, domain)
      end

      let(:domain) { "resource: action_schema" }
      let(:old_definition) { "Old definition" }

      context "when entity is nil" do
        let(:entity) { nil }

        it { expect(generate_entity_definition).to be_empty }
      end

      context "when entity.subtype_of is empty" do
        let(:entity) do
          remark_items = [
            instance_double(
              "remark_items",
              id: "__note",
              remarks: ["Some old note"],
            ),
          ]

          instance_double(
            "entity",
            id: "action_item",
            subtype_of: [],
            remark_items: remark_items,
          )
        end

        let(:expected_output) do
          "{{entity data type}} that represents the action item {{entity}}"
        end

        it { expect(generate_entity_definition).to eq(expected_output) }
      end

      context "when entity.subtype_of contains single entity" do
        let(:entity) do
          instance_double(
            "entity",
            id: "executed_action",
            subtype_of: [
              instance_double("entity", id: "action"),
            ],
            remark_items: [],
          )
        end

        let(:expected_output) do
          "{{entity data type}} that is a type of {{action}} that represents the executed action {{entity}}"
        end

        it { expect(generate_entity_definition).to eq(expected_output) }
      end

      context "when entity.subtype_of contains multiple entities" do
        let(:entity) do
          instance_double(
            "entity",
            id: "executed_action",
            subtype_of: [
              instance_double("entity", id: "action_1"),
              instance_double("entity", id: "action_2"),
            ],
            remark_items: [],
          )
        end

        let(:expected_output) do
          "{{entity data type}} that is a type of {{action_1}} and {{action_2}} that represents the executed action {{entity}}"
        end

        it { expect(generate_entity_definition).to eq(expected_output) }
      end
    end

    describe "#format_remark_items" do
      let(:format_remark_items) do
        subject.send(:format_remark_items, remark_items)
      end

      context "when remark_items is empty" do
        let(:remark_items) { [] }

        it { expect(format_remark_items).to be_empty }
      end

      context "when remark_items is not empty" do
        let(:remark_items) do
          [
            instance_double(
              "remark_items",
              id: "__note",
              remarks: ["Some old note"],
            ),

            instance_double(
              "remark_items",
              id: "__example",
              remarks: ["Some old example"],
            ),
          ]
        end

        let(:expected_output) do
          <<~OUTPUT

            [NOTE]
            --
            Some old note
            --

            [example]
            ====
            Some old example
            ====
          OUTPUT
        end

        it { expect(format_remark_items).to eq(expected_output) }
      end
    end

    describe "#format_remarks" do
      let(:format_remarks) do
        subject.send(:format_remarks, remarks, remark_item_name, remark_item_symbol)
      end

      let(:remark_item_name) { "NOTE" }
      let(:remark_item_symbol) { "--" }

      context "when remarks are empty" do
        let(:remarks) { [] }

        it { expect(format_remarks).to be_empty }
      end

      context "when remarks are not empty" do
        let(:remarks) do
          [
            "Some old note 1",
            "Some old note 2",
          ]
        end

        let(:expected_output) do
          <<~OUTPUT

            [NOTE]
            --
            Some old note 1
            --

            [NOTE]
            --
            Some old note 2
            --
          OUTPUT
        end

        it { expect(format_remarks).to eq(expected_output) }
      end
    end

    describe "#extract_file_type" do
      let(:extract_file_type) do
        subject.send(:extract_file_type, filename)
      end

      context "when file name is of resource" do
        let(:filename) { "action_schema_annotated.exp" }

        it { expect(extract_file_type).to eq("resource") }
      end

      context "when file name is of module" do
        context "when mim" do
          let(:filename) { "mim_annotated.exp" }

          it { expect(extract_file_type).to eq("module_mim") }
        end

        context "when arm" do
          let(:filename) { "arm_annotated.exp" }

          it { expect(extract_file_type).to eq("module_arm") }
        end
      end
    end
  end
end
