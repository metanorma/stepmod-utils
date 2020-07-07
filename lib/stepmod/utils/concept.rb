module Stepmod
  module Utils

    class Concept
      attr_accessor *%w(
        designation
        definition
        reference_anchor
        reference_clause
        examples
        notes
        synonym
        converted_definition
        file_path
      )

      def initialize(options)
        options.each_pair do |k, v|
          send("#{k}=", v)
        end
      end

      def self.parse(definition_xml, reference_anchor:, reference_clause:, file_path:)
        new(
          converted_definition: Stepmod::Utils::StepmodDefinitionConverter.convert(definition_xml),
          reference_anchor: reference_anchor,
          reference_clause: reference_clause,
          file_path: file_path
        )
      end

      def to_mn_adoc
        <<~TEXT
          // STEPmod path: #{file_path}
          #{converted_definition}

          [.source]
          <<#{reference_anchor},clause=#{reference_clause}>>

        TEXT
      end

    end
  end
end
