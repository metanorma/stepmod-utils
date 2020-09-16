# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Sub < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          content = treat_children(node, state)
          "#{content[/^\s*/]}~#{content.strip}~#{content[/\s*$/]}"
        end
      end

      ReverseAdoc::Converters.register :sub, Sub.new
    end
  end
end