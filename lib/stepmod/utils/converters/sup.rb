# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Sup < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          content = treat_children(node, state)
          "#{content[/^\s*/]}^#{content.strip}^#{content[/\s*$/]}"
        end
      end

      ReverseAdoc::Converters.register :sup, Sup.new
    end
  end
end