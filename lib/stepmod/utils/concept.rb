module Stepmod
  module Utils

    class Concept
      attr_accessor *%w(designation definition reference_anchor reference_clause examples notes synonym converted_definition)

      def initialize(options)
        options.each_pair do |k, v|
          send("#{k}=", v)
        end
      end

      def self.parse(definition_xml, reference_anchor:, reference_clause:)
        new(
          converted_definition: Stepmod::Utils::StepmodDefinitionConverter.convert(definition_xml),
          reference_anchor: reference_anchor,
          reference_clause: reference_clause
        )
      end

      def to_mn_adoc
        <<~TEXT
          #{converted_definition}

          [.source]
          <<#{reference_anchor},clause=#{reference_clause}>>
        TEXT
      end

    end
  end
end
