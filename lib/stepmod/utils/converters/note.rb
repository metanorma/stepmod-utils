# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Note < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          # If we want to skip this node
          return "" if state[:no_notes_examples]

          <<~TEMPLATE

            [NOTE]
            --
            #{treat_children(node, state).strip}
            --

          TEMPLATE
        end
      end
      ReverseAdoc::Converters.register :note, Note.new
    end
  end
end
