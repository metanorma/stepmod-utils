# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Introduction < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          <<~TEMPLATE
            == Introduction

            #{treat_children(node, state)}
          TEMPLATE
        end
      end

      ReverseAdoc::Converters.register :introduction, Introduction.new
    end
  end
end