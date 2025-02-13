# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Schema < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          state = state.merge(schema_name: node["name"])
          <<~TEMPLATE
            (*"#{node['name']}"
            #{treat_children(node, state).strip}
            *)
          TEMPLATE
        end
      end
      Coradoc::Input::HTML::Converters.register :schema, Schema.new
    end
  end
end
