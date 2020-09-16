# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class FundCons < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          <<~TEMPLATE
            == Fundamental concerns

            #{treat_children(node, state)}
          TEMPLATE
        end
      end

      ReverseAdoc::Converters.register :fund_cons, FundCons.new
    end
  end
end