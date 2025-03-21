require "glossarist"

module Stepmod
  module Utils
    class Term < Glossarist::LocalizedConcept
      # Term acronym
      attr_accessor :acronym

      def to_mn_adoc
        mn_adoc = ["=== #{definition.map(&:content).join}"]

        designations.each do |designation|
          mn_adoc << if designation.type == "abbreviation" && designation.acronym
                       "\nalt:[#{designation.designation}]"
                     else
                       "\n\n#{designation.designation}"
                     end
        end

        mn_adoc.join
      end

      class << self
        def from_h(hash)
          _, definition, acronym = treat_acronym(hash["definition"])

          concept_data = Glossarist::ConceptData.new(
            {
              definition: [
                Glossarist::DetailedDefinition.new({ content: definition }),
              ],
              terms: [],
            },
          )

          add_designations(concept_data, hash["synonyms"]) if hash["synonyms"]

          if acronym
            acronym = designation_object(acronym.gsub(/\(|\)/, ""),
                                         "abbreviation")
            acronym.acronym = true
            concept_data.terms << acronym
          end

          new({ data: concept_data })
        end

        private

        def add_designations(concept_data, synonyms)
          synonyms.each do |synonym|
            concept_data.terms << designation_object(synonym)
          end
        end

        def designation_object(value, type = "expression")
          Glossarist::Designation::Base.from_yaml(
            {
              "designation" => value,
              "type" => type,
            }.to_yaml,
          )
        end

        def treat_acronym(term_def)
          return [nil, term_def.strip, nil] unless term_def.match?(/.+\(.+?\)$/)

          term_def.match(/(.+?)(\(.+\))$/).to_a
        end
      end
    end
  end
end
