# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Sup < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          content = treat_children(node, state)
          return stem_notation(content) if node.parent.name == 'eqn'

          "#{content[/^\s*/]}^#{content.strip}^#{content[/\s*$/]}"
        end

        def stem_notation(content)
          "^{#{content}}"
        end
      end

      ReverseAdoc::Converters.register :sup, Sup.new
    end
  end
end