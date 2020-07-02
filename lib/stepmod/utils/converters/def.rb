require 'stepmod/utils/converters/def_text'

module Stepmod
  module Utils
    module Converters
      class Def < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          "#{additional_block(node)}#{treat_children(node, state)}"
        end

        private

        def treat(node, state)
          if node.name == 'text'
            return '' if node.text.strip.empty?
            return Stepmod::Utils::Converters::DefText.new.convert(node, state)
          end

          ReverseAsciidoctor::Converters.lookup(node.name).convert(node, state)
        end

        def additional_block(node)
          # Treat first `p` tag as an `alt` block, metanorma/stepmod-utils#9
          first_child_tag = node
                              .children
                              .find { |n| n.is_a?(Nokogiri::XML::Element) }
          return unless first_child_tag&.name == 'p' &&
                          defined?(Stepmod::Utils::Converters::Synonym)

          result = Stepmod::Utils::Converters::Synonym
                    .new
                    .convert(first_child_tag)
          first_child_tag.remove
          result
        end
      end

      ReverseAsciidoctor::Converters.register :def, Def.new
    end
  end
end
