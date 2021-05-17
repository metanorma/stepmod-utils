module Stepmod
  module Utils
    module Converters
      class StepmodExtDescription < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          state = state.merge(schema_name: node['linkend'])
          linkend = node['linkend'].split('.')

          # We only want ENTITY entries, not their attributes
          # https://github.com/metanorma/iso-10303-2/issues/36#issuecomment-841300092
          return nil if linkend.length != 2

          child_text = treat_children(node, state).strip
          return nil if child_text.empty?

          # Only taking the first paragraph of the definition
          child_text = child_text.split("\n").first

          # # Only taking the first sentence
          # if child_text.contains?(".")
          #   child_text = child_text.split(".").first
          # end

          domain =  case linkend.first
                    when /_mim$/, /_arm$/
                      "STEP module"
                    # when /_schema$/
                    else
                      "STEP resource"
                    end

          <<~TEMPLATE
            === #{linkend.last}

            #{domain ? "domain:[" + domain + "]" : ""}

            #{child_text}
          TEMPLATE
        end
      end
      ReverseAdoc::Converters.register :ext_description, StepmodExtDescription.new
    end
  end
end
