# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class FundCons < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          "\n\n== Fundamental concerns\n\n#{treat_children(node, state).strip}\n\n"
        end
      end

      ReverseAdoc::Converters.register :fund_cons, FundCons.new
    end
  end
end