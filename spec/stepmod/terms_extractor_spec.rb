require 'spec_helper'
require 'stepmod/utils/terms_extractor'

RSpec.describe Stepmod::Utils::TermsExtractor do
  subject(:call) { described_class.call(stepmod_dir, StringIO.new) }

  describe '.call' do
    let(:stepmod_dir) { fixtures_path('stepmod_terms_mock_directory') }
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

      domain:[STEP resource]

      An *action_directive* is an authoritative instrument that provides directions to achieve the specified results.


      NOTE: This term is incompletely defined in this document.
      Reference <<ISO_10303-41_2021>> for the complete definition.
      TEXT
    end
    let(:arm_description_xml_converted_definition) do
      <<~TEXT
        === Activity

        domain:[STEP module]

        An *Activity* is the identification of the occurrence of an action that has taken place, is taking place, or is expected to take place in the future. The procedure executed during that *Activity* is identified with the <<express:Activity_method_arm.Activity_method,Activity_method>> that is referred to by the *chosen_method* attribute.


        NOTE: This term is incompletely defined in this document.
        Reference <<ISO-TS_10303-1047_2014>> for the complete definition.
      TEXT
    end
    let(:mim_description_converted_definition) do
      <<~TEXT
      === applied_action_assignment

      domain:[STEP module]

      An *applied_action_assignment* is an <<express:action_schema.action,action>> related to the data that are affected by the <<express:action_schema.action,action>>. An *applied_action_assignment* is a type of <<express:management_resources_schema.action_assignment,action_assignment>>.


      NOTE: This term is incompletely defined in this document.
      Reference <<ISO-TS_10303-1047_2014>> for the complete definition.
      TEXT
    end

    it 'returns general_concepts, resource_concepts, parsed_bibliography lists' do
      expect(call.map(&:length)).to(eq([8, 0, 139, 1, 1, 1]))
    end

    it 'For resource.xml terms takes only the first paragraph and no additonal tags ' do
      agreement_common_understanding_concept = call[3][0][1]
        .find { |concept| concept.reference_anchor == 'ISO_10303-41_2021' && concept.reference_clause == '3.1' }
      expect(agreement_common_understanding_concept.converted_definition).to(eq(resource_xml_converted_definition.strip))
    end

    it 'For module.xml terms takes only the first paragraph and no additonal tags ' do
      activity_concept = call[0]
        .find { |concept| concept.reference_anchor == 'ISO-TS_10303-1047_2014' && concept.reference_clause == '3.1' }
      expect(activity_concept.converted_definition).to(eq(module_xml_converted_definition.strip))
    end

    it 'For business_object_model.xml terms takes only the first paragraph and no additonal tags ' do
      design_phase = call[0]
        .find { |concept| concept.reference_anchor == 'ISO-TS_10303-3001_2018' && concept.reference_clause == '3.1' }
      expect(design_phase.converted_definition.strip)
        .to(eq(business_object_model_converted_definition.strip))
    end

    it 'For resources/*/descriptions.xml terms takes only the first paragraph and no additonal tags ' do
      ReverseAdoc::Converters.unregister :ext_description
      ReverseAdoc::Converters
        .register(:ext_description,
          Stepmod::Utils::Converters::StepmodExtDescription.new)
      action_directive_concept = call[4][0][1].find { |concept| concept.converted_definition =~ /^=== action_directive/ }
      expect(action_directive_concept.converted_definition.strip)
        .to(eq(resource_description_converted_definition.strip))
    end

    it 'For modules/*/aim_descriptions.xml terms takes only the first paragraph and no additonal tags ' do
      ReverseAdoc::Converters.unregister :ext_description
      ReverseAdoc::Converters
        .register(:ext_description,
          Stepmod::Utils::Converters::StepmodExtDescription.new)
      activity_arm_concept = call[-1][0][1]['Activity_arm']
        .find { |concept| concept.converted_definition =~ /^=== Activity/ }
      expect(activity_arm_concept.converted_definition.strip)
        .to(eq(arm_description_xml_converted_definition.strip))
    end

    it 'For modules/*/mim_descriptions.xml terms takes only the first paragraph and no additonal tags ' do
      ReverseAdoc::Converters.unregister :ext_description
      ReverseAdoc::Converters
        .register(:ext_description,
          Stepmod::Utils::Converters::StepmodExtDescription.new)
      applied_action_assignment_concept = call[-1][0][2]['Activity_mim']
        .find { |concept| concept.converted_definition =~ /^=== applied_action_assignment/ }
      expect(applied_action_assignment_concept.converted_definition.strip)
        .to(eq(mim_description_converted_definition.strip))
    end
  end
end
