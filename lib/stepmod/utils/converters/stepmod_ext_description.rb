module Stepmod
  module Utils
    module Converters
      class StepmodExtDescription < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          state = state.merge(schema_name: node['linkend'])
          linkend = node['linkend'].split('.')

          # We ignore all the WHERE and IP rules because those are not terms
          case linkend.last
          when /^wr/, /^ur/
            return nil
          end

          child_text = treat_children(node, state).strip
          return nil if child_text.empty?

          domain =  case linkend.first
                    when /_mim$/, /_arm$/
                      "<STEP module>"
                    # when /_schema$/
                    else
                      "<STEP resource>"
                    end

          <<~TEMPLATE
            === #{linkend.join('.')}

            #{domain ? domain + " " : ""}#{treat_children(node, state).strip}
          TEMPLATE
        end
      end
      ReverseAdoc::Converters.register :ext_description, StepmodExtDescription.new
    end
  end
end
