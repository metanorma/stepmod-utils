# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Introduction < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          treat_children(node, state)
        end
      end

      ReverseAdoc::Converters.register :introduction, Introduction.new
    end
  end
end