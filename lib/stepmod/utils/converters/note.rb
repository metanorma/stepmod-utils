# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Note < ReverseAdoc::Converters::Base
        def convert(node, state = {})
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