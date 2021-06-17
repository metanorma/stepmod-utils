# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Code < ReverseAdoc::Converters::Base
        def convert(node, _state = {})
          "`#{node.text}`"
        end
      end

      ReverseAdoc::Converters.register :code, Code.new
      ReverseAdoc::Converters.register :tt, Code.new
      ReverseAdoc::Converters.register :kbd, Code.new
      ReverseAdoc::Converters.register :samp, Code.new
      ReverseAdoc::Converters.register :var, Code.new
    end
  end
end
