# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Dt < Stepmod::Utils::Converters::Base
        def convert(node, _state = {})
          return "\n\n{blank}::" if node.text.strip.length.zero?

          "\n\n#{node.text}:: "
        end

        ReverseAdoc::Converters.register :dt, Dt.new
      end
    end
  end
end
