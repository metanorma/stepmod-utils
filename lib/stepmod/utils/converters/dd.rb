# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Dd < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          "#{node.text}\n"
        end

        ReverseAdoc::Converters.register :dd, Dd.new
      end
    end
  end
end