# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Example < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          "\n\n[example]\n====\n#{treat_children(node, state).strip}\n====\n\n"
        end
      end
      ReverseAdoc::Converters.register :example, Example.new
    end
  end
end