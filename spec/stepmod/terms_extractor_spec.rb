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
    let(:stepmod_dir) { fixtures_path('stepmod_terms_mock_directory') }
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
    let(:resource_description_converted_definition) do
      <<~TEXT
        === action_directive
        domain:[resource: action_schema]

        entity data type that represents an action_directive entity

        [NOTE]
        --
        An *action_directive* is an authoritative instrument that provides directions to achieve the specified results.
        --

        [EXAMPLE]
        ====
        ISO Directives Part 3 provides guidance for the development of standards documents within ISO.
        ====
      TEXT
    end
    let(:arm_description_xml_converted_definition) do
      <<~TEXT
        === Activity
        domain:[application module: Activity_arm]

        entity data type that represents an Activity entity

        [NOTE]
        --
        An *Activity* is the identification of the occurrence of an action that has taken place, is taking place, or is expected to take place in the future. The procedure executed during that *Activity* is identified with the <<express:Activity_method_arm.Activity_method,Activity_method>> that is referred to by the *chosen_method* attribute.
        --

        [NOTE]
        --
        Status information identifying the level of completion of each activity may be provided within an instance of <<express:Activity_arm.Activity_status,Activity_status>>.
        --

        [NOTE]
        --
        The items that are affected by an *Activity*, for example as input or output, may be identified within an instance of <<express:Activity_arm.Applied_activity_assignment,Applied_activity_assignment>>.
        --

        [EXAMPLE]
        ====
        Change, distilling, design, a process to drill a hole, and a task such as training someone, are examples of activities.
        ====
      TEXT
    end
    let(:mim_description_converted_definition) do
      <<~TEXT
        === applied_action_assignment
        domain:[application module: Activity_mim]

        entity data type that is a type of action_assignment that represents an applied_action_assignment entity

        [NOTE]
        --
        An *applied_action_assignment* is an <<express:action_schema.action,action>> related to the data that are affected by the <<express:action_schema.action,action>>. An *applied_action_assignment* is a type of <<express:management_resources_schema.action_assignment,action_assignment>>.
        --
      TEXT
    end

    it "returns general_concepts, \
      resource_concepts, parsed_bibliography lists" do
      expect(call.map(&:to_a).map(&:length)).to(eq([8, 0, 41, 1, 1, 1]))
    end

    it "For resource.xml terms takes only the \
      first paragraph and no additonal tags " do
      agreement_common_understanding_concept = call[3][0][1]
        .find do |concept|
          concept.localizations["en"].reference_anchor == "ISO_10303-41_2021" &&
            concept.localizations["en"].reference_clause == "3.1"
        end
        .localizations["en"]
      expect(agreement_common_understanding_concept.converted_definition)
        .to(eq(resource_xml_converted_definition.strip))
    end

    it "For module.xml terms takes only the first \
      paragraph and no additonal tags " do
      activity_concept = call[0]
        .find do |concept|
          concept
            .localizations["en"]
            .reference_anchor == "ISO-TS_10303-1047_2014" &&
            concept.localizations["en"].reference_clause == "3.1"
        end
        .localizations["en"]
      expect(activity_concept.converted_definition)
        .to(eq(module_xml_converted_definition.strip))
    end

    it "For business_object_model.xml terms takes only the \
      first paragraph and no additonal tags " do
      design_phase = call[0]
        .find do |concept|
          concept
            .localizations["en"]
            .reference_anchor == "ISO-TS_10303-3001_2018" &&
            concept.localizations["en"].reference_clause == "3.1"
        end
        .localizations["en"]
      expect(design_phase.converted_definition.strip)
        .to(eq(business_object_model_converted_definition.strip))
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
            .converted_definition =~ /^=== action_directive/
        end
        .localizations["en"]
      expect(action_directive_concept.converted_definition.strip)
        .to(eq(resource_description_converted_definition.strip))
    end

    it "For modules/*/aim_descriptions.xml terms takes only the first \
      paragraph and no additonal tags " do
      ReverseAdoc::Converters.unregister :ext_description
      ReverseAdoc::Converters
        .register(:ext_description,
                  Stepmod::Utils::Converters::StepmodExtDescription.new)
      activity_arm_concept = call[-1][0][1]["Activity_arm"]
        .to_a.map { |n| n.localizations["en"] }
        .find { |concept| concept.converted_definition =~ /^=== Activity/ }
      expect(activity_arm_concept.converted_definition.strip)
        .to(eq(arm_description_xml_converted_definition.strip))
    end

    it "For modules/*/mim_descriptions.xml terms takes only the first \
      paragraph and no additonal tags " do
      ReverseAdoc::Converters.unregister :ext_description
      ReverseAdoc::Converters
        .register(:ext_description,
                  Stepmod::Utils::Converters::StepmodExtDescription.new)
      applied_action_assignment_concept = call[-1][0][2]["Activity_mim"]
        .to_a.map { |n| n.localizations["en"] }
        .find do |concept|
          concept.converted_definition =~ /^=== applied_action_assignment/
        end
      expect(applied_action_assignment_concept.converted_definition.strip)
        .to(eq(mim_description_converted_definition.strip))
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
        subject.send(:generate_entity_definition, entity, domain, old_definition)
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
            id: "action_schema",
            subtype_of: [],
            remark_items: remark_items,
          )
        end

        let(:expected_output) do
          <<~OUTPUT
            === action_schema
            domain:[resource: action_schema]

            entity data type that represents an action_schema entity

            [NOTE]
            --
            Old definition
            --

            [NOTE]
            --
            Some old note
            --
          OUTPUT
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
          <<~OUTPUT
            === executed_action
            domain:[resource: action_schema]

            entity data type that is a type of action that represents an executed_action entity

            [NOTE]
            --
            Old definition
            --
          OUTPUT
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
          <<~OUTPUT
            === executed_action
            domain:[resource: action_schema]

            entity data type that is a type of action_1 and action_2 that represents an executed_action entity

            [NOTE]
            --
            Old definition
            --
          OUTPUT
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

            [EXAMPLE]
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
  end
end
