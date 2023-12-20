# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Q < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          content = treat_children(node, state)
          "#{content[/^\s*/]}\"#{content.strip}\"#{content[/\s*$/]}"
        end
      end

      ReverseAdoc::Converters.register :q, Q.new
    end
  end
end
