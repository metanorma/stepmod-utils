require "glossarist"

module Stepmod
  module Utils
    class Concept < Glossarist::LocalizedConcept
      attr_accessor *%w(
        reference_clause
        reference_anchor
        converted_definition
        file_path
      )

      class << self
        def parse(definition_xml, reference_anchor:, reference_clause:, file_path:, language_code: "en")
          converted_definition = Stepmod::Utils::StepmodDefinitionConverter.convert(
            definition_xml,
            {
              # We don't want examples and notes
              no_notes_examples: true,
              reference_anchor: reference_anchor,
            },
          )

          return nil if converted_definition.nil? || converted_definition.strip.empty?

          if definition_xml.name == "ext_description"
            converted_definition = <<~TEXT
              #{converted_definition}

              NOTE: This term is incompletely defined in this document.
              Reference <<#{reference_anchor}>> for the complete definition.
            TEXT
          end
          # https://github.com/metanorma/stepmod-utils/issues/86
          if definition_xml.name == "definition"
            designation = definition_designation(definition_xml)
            definition = definition_xml_definition(definition_xml,
                                                   reference_anchor)
            converted_definition = definition_xml_converted_definition(
              designation, definition
            ).strip
          end
          new(
            designations: [designation],
            definition: definition,
            converted_definition: converted_definition,
            id: "#{reference_anchor}.#{reference_clause}",
            reference_anchor: reference_anchor,
            reference_clause: reference_clause,
            file_path: file_path,
            language_code: language_code,
          )
        end

        def definition_designation(definition_xml)
          alts = definition_xml.xpath(".//def/p").map(&:text)
          {
            accepted: definition_xml.xpath(".//term").first&.text,
            alt: alts,
          }
        end

        def definition_xml_definition(definition_xml, reference_anchor)
          text_nodes = definition_xml
            .xpath(".//def")
            .first
            .children
            .reject { |n| n.name == "p" }
          wrapper = "<def>#{text_nodes.map(&:to_s).join}</def>"
          Stepmod::Utils::Converters::Def
            .new
            .convert(
              Nokogiri::XML(wrapper).root,
              {
                # We don't want examples and notes
                no_notes_examples: true,
                reference_anchor: reference_anchor,
              },
            )
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
          // STEPmod path:#{!file_path.empty? ? " #{file_path}" : ''}
          #{converted_definition}

          [.source]
          <<#{reference_anchor}#{reference_clause ? ",clause=#{reference_clause}" : ''}>>

        TEXT
      end
    end
  end
end
