# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Introduction < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          "\n\n== Introduction\n\n#{treat_children(node, state).strip}\n\n"
        end
      end

      ReverseAdoc::Converters.register :introduction, Introduction.new
    end
  end
end