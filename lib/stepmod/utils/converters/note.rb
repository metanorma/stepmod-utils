# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Note < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
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
      Coradoc::Input::HTML::Converters.register :note, Note.new
    end
  end
end
