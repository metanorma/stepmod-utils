# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Example < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          # If we want to skip this node
          return "" if state[:no_notes_examples]

          <<~TEMPLATE


            [example]
            ====
            #{treat_children(node, state).strip}
            ====

          TEMPLATE
        end
      end
      Coradoc::Input::Html::Converters.register :example, Example.new
    end
  end
end
