# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Hr < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          "\n* * *\n"
        end
      end

      ReverseAdoc::Converters.register :hr, Hr.new
    end
  end
end