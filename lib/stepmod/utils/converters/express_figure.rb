# frozen_string_literal: true

require_relative "./figure"

module Stepmod
  module Utils
    module Converters
      class ExpressFigure < Stepmod::Utils::Converters::Figure
        # def self.pattern(state, id)
        #   "figure-exp-#{id}"
        # end

        def to_coradoc(node, state = {})
          <<~TEMPLATE
            (*"#{state[:schema_and_entity]}.__figure"
            #{super(node, state.merge(no_notes_examples: nil)).strip}
            *)
          TEMPLATE
        end
      end

      Coradoc::Input::Html::Converters.register :express_figure,
                                                ExpressFigure.new
    end
  end
end
