# frozen_string_literal: true

require 'stepmod/utils/converters/synonym'

module Stepmod
  module Utils
    module Converters
      class Term < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          first_child = node.children.find do |child|
                          child.name == 'text' && !child.text.to_s.strip.empty?
                        end
          unless first_child &&
                  node.text.split(';').length == 2 &&
                  defined?(Stepmod::Utils::Converters::Synonym)
            return "=== #{treat_children(node, state).strip}"
          end

          term_def, alt = node.text.split(';')
          alt_xml = Nokogiri::XML::Text.new(alt, Nokogiri::XML::Document.new)
          converted_alt = Stepmod::Utils::Converters::Synonym.new.convert(alt_xml)
          "=== #{term_def}\n\n#{converted_alt}"
        end
      end

      ReverseAdoc::Converters.register :term, Term.new
    end
  end
end