# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Example < ReverseAdoc::Converters::Base
        def convert(node, state = {})

          # If we want to skip this node
          return '' if state[:no_notes_examples]

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
