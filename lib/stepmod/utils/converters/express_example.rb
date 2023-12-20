# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExpressExample < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          <<~TEMPLATE
            (*"#{state[:schema_and_entity]}.__example"
            #{treat_children(node, state).strip}
            *)
          TEMPLATE
        end
      end

      ReverseAdoc::Converters.register :express_example, ExpressExample.new
    end
  end
end
