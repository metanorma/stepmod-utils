# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Dd < Stepmod::Utils::Converters::Base
        def convert(node, _state = {})
          "#{node.text}\n"
        end

        ReverseAdoc::Converters.register :dd, Dd.new
      end
    end
  end
end
