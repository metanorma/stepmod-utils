# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Dl < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          treat_children(node, state)
        end

        ReverseAdoc::Converters.register :dl, Dl.new
      end
    end
  end
end
