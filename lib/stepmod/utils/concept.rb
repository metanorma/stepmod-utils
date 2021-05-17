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
        converted_definition = Stepmod::Utils::StepmodDefinitionConverter.convert(
          definition_xml,
          {
            # We don't want examples and notes
            no_notes_examples: true,
            reference_anchor: reference_anchor
          }
        )

        return nil if converted_definition.nil? || converted_definition.strip.empty?

        if definition_xml.name == 'ext_description'
          converted_definition = <<~TEXT
            #{converted_definition}

            NOTE: This term is incompletely defined in this document.
            Reference <<#{reference_anchor}>> for the complete definition.
          TEXT
        end
        new(
          converted_definition: converted_definition,
          reference_anchor: reference_anchor,
          reference_clause: reference_clause,
          file_path: file_path
        )
      end

      def to_mn_adoc
        <<~TEXT
          // STEPmod path:#{!file_path.empty? ? " " + file_path : ""}
          #{converted_definition}

          [.source]
          <<#{reference_anchor}#{reference_clause ? ",clause=" + reference_clause : ""}>>

        TEXT
      end

    end
  end
end
