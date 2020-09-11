# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Note < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          "\n\n[NOTE]\n--\n#{treat_children(node, state).strip}\n--\n\n"
        end
      end
      ReverseAdoc::Converters.register :note, Note.new
    end
  end
end