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

      class << self
        def parse(definition_xml, reference_anchor:, reference_clause:, file_path:)
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
          # https://github.com/metanorma/stepmod-utils/issues/86
          if definition_xml.name == 'definition'
            designation = definition_designation(definition_xml)
            definition = definition_xml_definition(definition_xml)
            converted_definition = definition_xml_converted_definition(designation, definition).strip
          end
          new(
            designation: designation,
            definition: definition,
            converted_definition: converted_definition,
            reference_anchor: reference_anchor,
            reference_clause: reference_clause,
            file_path: file_path
          )
        end

        def definition_designation(definition_xml)
          alts = definition_xml.xpath('.//def/p').map(&:text)
          {
            accepted: definition_xml.xpath('.//term').first&.text,
            alt: alts
          }
        end

        def definition_xml_definition(definition_xml)
          definition_xml
            .xpath('.//def')
            .first
            .children
            .find_all(&:text?)
            .map { |n| n.text.strip.gsub("\n", "").gsub(/\s+/, ' ')  }
            .join
        end

        def definition_xml_converted_definition(designation, definition)
          if designation[:alt].length.positive?
            alt_notation = "alt:[#{designation[:alt].map(&:strip).join(',')}]"
          end
          result = <<~TEXT
            === #{designation[:accepted]}
          TEXT
          if alt_notation
            result += <<~TEXT

              #{alt_notation}
            TEXT
          end
          <<~TEXT
            #{result}
            #{definition}
          TEXT
        end
      end

      def to_mn_adoc
        <<~TEXT
          // STEPmod path:#{!file_path.empty? ? " #{file_path}" : ""}
          #{converted_definition}

          [.source]
          <<#{reference_anchor}#{reference_clause ? ",clause=" + reference_clause : ""}>>

        TEXT
      end

    end
  end
end
