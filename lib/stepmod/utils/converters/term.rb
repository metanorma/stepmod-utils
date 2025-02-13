# frozen_string_literal: true

require "stepmod/utils/converters/synonym"
require "stepmod/utils/term"
require "glossarist"

module Stepmod
  module Utils
    module Converters
      class Term < Stepmod::Utils::Converters::Base
        # We strip all the children in the case for "stem:[d]-manifold"
        # vs "stem:[d] -manifold"
        def treat_children(node, state)
          res = node.children.map { |child| treat(child, state) }
          res.map(&:strip).reject(&:empty?).join("")
        end

        def to_coradoc(node, state = {})
          first_child = node.children.find do |child|
            child.name == "text" && !child.text.to_s.strip.empty?
          end

          unless first_child &&
              node.text.split(";").length == 2 &&
              defined?(Stepmod::Utils::Converters::Synonym)

            return Stepmod::Utils::Term.from_h(
              "definition" => treat_children(node, state).strip,
            ).to_mn_adoc
          end

          term_def, alt = node.text.split(";")
          alt_xml = Nokogiri::XML::Text.new(alt, Nokogiri::XML::Document.new)
          converted_alt = Stepmod::Utils::Converters::Synonym.new.convert(alt_xml)

          Stepmod::Utils::Term.from_h(
            "definition" => term_def,
            "synonyms" => [converted_alt],
          ).to_mn_adoc
        end
      end

      Coradoc::Input::HTML::Converters.register :term, Term.new
    end
  end
end
