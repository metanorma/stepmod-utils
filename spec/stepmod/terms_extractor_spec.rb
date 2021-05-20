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

    it 'returns general_concepts, resource_concepts, parsed_bibliography lists' do
      expect(call.map(&:length)).to(eq([1, 0, 132, 1, 1, 1]))
    end

    it 'For resource.xml terms takes only the first paragraph and no additonal tags ' do
      agreement_common_understanding_concept = call[3][0][1].find { |concept| concept.reference_anchor == 'ISO_10303-41_2021' && concept.reference_clause == '3.1' }
      expect(agreement_common_understanding_concept.converted_definition).to(eq(resource_xml_converted_definition.strip))
    end
  end
end
