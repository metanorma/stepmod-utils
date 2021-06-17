# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Synonym < ReverseAdoc::Converters::Base
        def convert(node, _state = {})
          "alt:[#{node.text.strip}]"
        end
      end

      ReverseAdoc::Converters.register :synonym, Synonym.new
    end
  end
end
