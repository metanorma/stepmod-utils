require "glossarist"

module Stepmod
  module Utils
    class Concept < Glossarist::LocalizedConcept
      attr_accessor *%w(
        reference_clause
        reference_anchor
        converted_definition
        file_path
        schema
        part
        domain
        document
      )

      # TODO: converted_definition is not supposed to be an attribute, it is
      # supposed to be a method!
      class << self
        def parse(definition_xml, reference_anchor:, reference_clause:, file_path:, language_code: "en")
          converted_definition = Stepmod::Utils::StepmodDefinitionConverter.convert(
            definition_xml,
            {
              # We don't want examples, notes, figures and tables
              no_notes_examples: true,
              reference_anchor: reference_anchor,
            },
          )

          return nil if converted_definition.nil? || converted_definition.strip.empty?

          # https://github.com/metanorma/stepmod-utils/issues/86

          # TODO: This portion DOES NOT HANDLE the <synonym> element. WTF??
          if definition_xml.name == "definition"
            designation = definition_designation(definition_xml)
            definition = definition_xml_definition(definition_xml,
                                                   reference_anchor)
            converted_definition = definition_xml_converted_definition(
              designation, definition
            ).strip
          end

          # TODO: `designations:` should include the `alt:[...]` terms here,
          # they are now only included in definition_xml_converted_definition.
          new(
            designations: designation,
            definition: [definition],
            converted_definition: converted_definition,
            id: "#{reference_anchor}.#{reference_clause}",
            reference_anchor: reference_anchor,
            reference_clause: reference_clause,
            file_path: file_path,
            language_code: language_code,
          )
        end

        def definition_designation(definition_xml)
          # We take the <p> that is an alternative term (length<=20).
          # Add in the <synonym> elements.
          alts = definition_xml.xpath(".//synonym").map(&:text) +
            definition_xml.xpath(".//def/p").map(&:text).reject do |text|
              text.length > 20
            end

          term = Stepmod::Utils::Converters::Term
            .new
            .convert(
              definition_xml.xpath(".//term").first
            )

          # [4..-1] because we want to skip the initial `=== {title}`
          designations = [
            { "designation" => term[4..-1], "type" => "expression", "normative_status" => "preferred" },
          ]

          alts.each do |alt|
            designations << { "designation" => alt, "type" => "expression" }
          end

          designations
        end

        def definition_xml_definition(definition_xml, reference_anchor)
          # We reject the <p> that was considered an alternative term (length<=20)
          text_nodes = definition_xml
            .xpath(".//def")
            .first
            .children
            .reject { |n| n.name == "p" && n.text.length <= 20 }

          wrapper = "<def>#{text_nodes.map(&:to_s).join}</def>"

          Stepmod::Utils::Converters::Def
            .new
            .convert(
              Nokogiri::XML(wrapper).root,
              {
                # We don't want examples, notes, figures and tables
                no_notes_examples: true,
                reference_anchor: reference_anchor,
              },
            )
        end

        def definition_xml_converted_definition(designation, definition)
          accepted_designation = designation.select do |des|
            des["normative_status"] == "preferred"
          end

          alt_designations = designation.reject do |des|
            des["normative_status"] == "preferred"
          end

          if alt_designations.length.positive?
            alt_designations_text = alt_designations.map do |d|
              d["designation"].strip
            end.join(",")

            alt_notation = "alt:[#{alt_designations_text}]"
          end

          result = <<~TEXT
            === #{accepted_designation.map { |d| d['designation'].strip }.join(',')}
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

      def to_h
        super.merge({
          "domain" => domain,
          "part" => part,
          "schema" => schema,
          "document" => document,
        }.compact)
      end

      def to_mn_adoc
        <<~TEXT
          // STEPmod path:#{file_path.empty? ? '' : " #{file_path}"}
          #{converted_definition}

          [.source]
          <<#{reference_anchor}#{reference_clause ? ",clause=#{reference_clause}" : ''}>>

        TEXT
      end
    end
  end
end
