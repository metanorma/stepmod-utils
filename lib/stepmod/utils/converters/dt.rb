# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Dt < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          "#{node.text}:: "
        end

        ReverseAdoc::Converters.register :dt, Dt.new
      end
    end
  end
end