# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Schema < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          <<~TEMPLATE
            (*"#{node['name']}"
            #{treat_children(node, state).strip}
            *)
          TEMPLATE
        end
      end
      ReverseAdoc::Converters.register :schema, Schema.new
    end
  end
end
