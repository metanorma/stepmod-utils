# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExpressNote < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          <<~TEMPLATE
            (*"#{state[:schema_and_entity]}.__note"
            #{treat_children(node, state).strip}
            *)
          TEMPLATE
        end
      end

      ReverseAdoc::Converters.register :express_note, ExpressNote.new
    end
  end
end
