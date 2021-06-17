# frozen_string_literal: true

require "reverse_adoc/converters/figure"

module Stepmod
  module Utils
    module Converters
      class Figure < ReverseAdoc::Converters::Figure
        def convert(node, state = {})
          # If we want to skip this node
          return "" if state[:no_notes_examples]

          super
        end
      end
      # This replaces the converter
      ReverseAdoc::Converters.register :figure, Figure.new
    end
  end
end
