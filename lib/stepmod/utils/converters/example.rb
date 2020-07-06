# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Example < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          <<~TEMPLATE
            [example]
            ====
            #{treat_children(node, state).strip}
            ====
          TEMPLATE
        end
      end
      ReverseAdoc::Converters.register :example, Example.new
    end
  end
end