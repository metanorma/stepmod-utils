# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Strong < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          content = treat_children(node, state.merge(already_strong: true))
          if content.strip.empty? || state[:already_strong]
            content
          else
            "#{content[/^\s*/]}*#{content.strip}*#{content[/\s*$/]}"
          end
        end
      end

      ReverseAdoc::Converters.register :strong, Strong.new
      ReverseAdoc::Converters.register :b,      Strong.new
    end
  end
end