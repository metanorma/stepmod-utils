# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Definition < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          treat_children(node, state)
        end

        private

        def treat_children(node, state)
          res = node.children.map { |child| treat(child, state) }
          res.map(&:strip).reject(&:empty?).join("\n\n")
        end
      end

      ReverseAdoc::Converters.register :definition, Definition.new
    end
  end
end
