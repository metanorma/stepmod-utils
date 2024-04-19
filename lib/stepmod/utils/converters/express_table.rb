# frozen_string_literal: true

require_relative "./table"

module Stepmod
  module Utils
    module Converters
      class ExpressTable < Stepmod::Utils::Converters::Table
        # def self.pattern(id)
        #   "table-exp-#{id}"
        # end

        def convert(node, state = {})
          <<~TEMPLATE
            (*"#{state[:schema_and_entity]}.__table"
            #{super(node, state.merge(no_notes_examples: nil)).strip}
            *)
          TEMPLATE
        end
      end

      ReverseAdoc::Converters.register :express_table, ExpressTable.new
    end
  end
end
