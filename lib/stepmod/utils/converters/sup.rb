# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Sup < Ceradoc::Html::Converters::Sup
        def to_coradoc(node, state = {})
          if state[:equation]
            stem_notation(treat_children(node,
                                         state))
          else
            super(node, state)
          end
        end

        def stem_notation(content)
          "^{#{content}}"
        end
      end

      Ceradoc::Html::Converters.register :sup, Sup.new
    end
  end
end
