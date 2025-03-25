# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Sub < Coradoc::Input::Html::Converters::Sub
        def to_coradoc(node, state = {})
          if state[:equation]
            stem_notation(treat_children(node,
                                         state))
          else
            super(node, state)
          end
        end

        private

        def stem_notation(content)
          "_{#{content}}"
        end
      end

      Coradoc::Input::Html::Converters.register :sub, Sub.new
    end
  end
end
