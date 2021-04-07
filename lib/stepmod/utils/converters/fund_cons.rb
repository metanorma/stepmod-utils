# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class FundCons < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          <<~TEXT

            *)
            (*"#{state.fetch(:schema_name)}.__fund_cons"

            #{treat_children(node, state).strip}
          TEXT
        end
      end

      ReverseAdoc::Converters.register :fund_cons, FundCons.new
    end
  end
end