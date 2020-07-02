# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Definition < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          treat_children(node, state)
        end

        private

        def treat_children(node, state)
          res = node.children.map { |child| treat(child, state) }
          res.map(&:strip).reject(&:empty?).join("\n\n")
        end
      end

      ReverseAsciidoctor::Converters.register :definition, Definition.new
    end
  end
end
