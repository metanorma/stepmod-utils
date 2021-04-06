module Stepmod
  module Utils
    module Converters
      class ExtDescription < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          state = state.merge(schema_name: node['linkend'])
          <<~TEMPLATE
            (*"#{node['linkend']}"
            #{treat_children(node, state).strip}
            *)
          TEMPLATE
        end
      end
      ReverseAdoc::Converters.register :ext_description, ExtDescription.new
    end
  end
end
