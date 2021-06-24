module Stepmod
  module Utils
    module Converters
      class ExtDescription < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          state = state.merge(schema_name: node["linkend"], non_flanking_whitesapce: true)
          child_text = treat_children(node, state).strip

          <<~TEMPLATE
            (*"#{node['linkend']}"
            #{child_text}
            *)
          TEMPLATE
        end
      end
      ReverseAdoc::Converters.register :ext_description, ExtDescription.new
    end
  end
end
