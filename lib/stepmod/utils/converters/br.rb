# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Br < Stepmod::Utils::Converters::Base
        def convert(_node, _state = {})
          " +\n"
        end
      end

      ReverseAdoc::Converters.register :br, Br.new
    end
  end
end
