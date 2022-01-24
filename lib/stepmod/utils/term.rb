require "glossarist"

module Stepmod
  module Utils
    class Term < Glossarist::LocalizedConcept
      # Term acronym
      attr_accessor :acronym

      def to_mn_adoc
        mn_adoc = ["=== #{definition}"]
        mn_adoc << "\nalt:[#{acronym}]" if acronym
        mn_adoc << "\n\n#{designations.join(", ")}" if designations&.any?

        mn_adoc.join
      end

      class << self
        def from_h(hash)
          _, definition, acronym = treat_acronym(hash["definition"])

          hash["definition"] = definition
          hash["acronym"] = acronym.gsub(/\(|\)/, "") if acronym
          hash["designations"] = hash["synonyms"]

          super(hash.reject { |k, _| k == "synonyms" })
        end

        private

        def treat_acronym(term_def)
          return [nil, term_def.strip, nil] unless term_def.match?(/.+\(.+?\)$/)

          term_def.match(/(.+?)(\(.+\))$/).to_a
        end
      end
    end
  end
end
