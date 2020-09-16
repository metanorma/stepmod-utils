# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExtDescriptions < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          treat_children(node, state)
        end
      end
      ReverseAdoc::Converters.register :ext_descriptions, ExtDescriptions.new
    end
  end
end
