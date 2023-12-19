# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Resource < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          treat_children(node, state)
        end
      end
      ReverseAdoc::Converters.register :resource, Resource.new
    end
  end
end
