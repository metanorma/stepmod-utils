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

        entity data type that represents a/an action_directive entity

        NOTE: An *action_directive* is an authoritative instrument that provides directions to achieve the specified results.
      TEXT
    end
    let(:arm_description_xml_converted_definition) do
      <<~TEXT
        === Activity

        domain:[module: Activity_arm]

        entity data type that represents a/an Activity entity

        NOTE: An *Activity* is the identification of the occurrence of an action that has taken place, is taking place, or is expected to take place in the future. The procedure executed during that *Activity* is identified with the <<express:Activity_method_arm.Activity_method,Activity_method>> that is referred to by the *chosen_method* attribute.
      TEXT
    end
    let(:mim_description_converted_definition) do
      <<~TEXT
        === applied_action_assignment

        domain:[module: Activity_mim]

        entity data type that is a type of action_assignment that represents a/an applied_action_assignment entity

        NOTE: An *applied_action_assignment* is an <<express:action_schema.action,action>> related to the data that are affected by the <<express:action_schema.action,action>>. An *applied_action_assignment* is a type of <<express:management_resources_schema.action_assignment,action_assignment>>.
      TEXT
    end

    it "returns general_concepts, \
      resource_concepts, parsed_bibliography lists" do
      expect(call.map(&:to_a).map(&:length)).to(eq([8, 0, 139, 1, 1, 1]))
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
end
