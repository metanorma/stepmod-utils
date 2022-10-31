require "glossarist"
require "pry"

module Stepmod
  module Utils
    class Term < Glossarist::LocalizedConcept
      # Term acronym
      attr_accessor :acronym

      def to_mn_adoc
        mn_adoc = ["=== #{definition.map(&:content).join}"]
        mn_adoc << "\nalt:[#{acronym}]" if acronym
        mn_adoc << "\n\n#{designations.map(&:designation).join(", ")}" if designations&.any?

        mn_adoc.join
      end

      class << self
        def from_h(hash)
          _, definition, acronym = treat_acronym(hash["definition"])

          hash["definition"] = [definition]

          hash["acronym"] = acronym.gsub(/\(|\)/, "") if acronym
          add_designations(hash, hash["synonyms"]) if hash["synonyms"]

          new(hash)
        end

        private

        def add_designations(hash, synonyms)
          hash["designations"] ||= []
          hash["designations"] << designation_hash(synonyms) if synonyms
        end

        def designation_hash(value, type = "expression")
          {
            "designation" => value,
            "type" => type,
          }
        end

        def treat_acronym(term_def)
          return [nil, term_def.strip, nil] unless term_def.match?(/.+\(.+?\)$/)

          term_def.match(/(.+?)(\(.+\))$/).to_a
        end
      end
    end
  end
end
