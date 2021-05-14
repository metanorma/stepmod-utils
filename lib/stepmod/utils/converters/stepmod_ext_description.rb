module Stepmod
  module Utils
    module Converters
      class StepmodExtDescription < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          state = state.merge(schema_name: node['linkend'])
          linkend = node['linkend'].split('.')

          # We ignore all the WHERE and IP rules because those are not terms
          return nil if linkend.last =~ /^wr/

          <<~TEMPLATE
            === #{node['linkend'].split('.').last}

            <STEP resource> #{treat_children(node, state).strip}
          TEMPLATE
        end
      end
      ReverseAdoc::Converters.register :ext_description, StepmodExtDescription.new
    end
  end
end
