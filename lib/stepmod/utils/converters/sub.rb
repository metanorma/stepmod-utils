# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Sub < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          content = treat_children(node, state)
          return stem_notation(content) if node.parent.name == 'eqn'

          "#{content[/^\s*/]}~#{content.strip}~#{content[/\s*$/]}"
        end

        private

        def stem_notation(content)
          "_{#{content}}"
        end
      end

      ReverseAdoc::Converters.register :sub, Sub.new
    end
  end
end