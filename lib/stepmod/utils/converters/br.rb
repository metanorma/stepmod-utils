# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Br < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          " +\n"
        end
      end

      ReverseAdoc::Converters.register :br, Br.new
    end
  end
end
