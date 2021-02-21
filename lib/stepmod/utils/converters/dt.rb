# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Dt < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          return "{blank}::" if node.text.strip.length.zero?

          "#{node.text}:: "
        end

        ReverseAdoc::Converters.register :dt, Dt.new
      end
    end
  end
end