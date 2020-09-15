# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Schema < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          node.children.map do |child|
            treat(child, state)
          end.join("\n\n")
        end
      end
      ReverseAdoc::Converters.register :schema, Schema.new
    end
  end
end
