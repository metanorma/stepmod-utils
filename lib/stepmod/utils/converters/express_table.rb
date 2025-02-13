# frozen_string_literal: true

require_relative "./table"

module Stepmod
  module Utils
    module Converters
      class ExpressTable < Stepmod::Utils::Converters::Table
        # def self.pattern(id)
        #   "table-exp-#{id}"
        # end

        def to_coradoc(node, state = {})
          <<~TEMPLATE
            (*"#{state[:schema_and_entity]}.__table"
            #{super(node, state.merge(no_notes_examples: nil)).strip}
            *)
          TEMPLATE
        end
      end

    end
  end
end
