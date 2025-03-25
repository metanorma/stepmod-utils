# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class FundCons < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          <<~TEXT

            *)
            (*"#{state.fetch(:schema_name)}.__fund_cons"

            #{treat_children(node, state).strip}
          TEXT
        end
      end

      Coradoc::Input::Html::Converters.register :fund_cons, FundCons.new
    end
  end
end
