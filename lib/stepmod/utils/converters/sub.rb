# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Sub < Coradoc::Input::HTML::Converters::Sub
        def to_coradoc(node, state = {})
          state[:equation] ? stem_notation(treat_children(node, state)) : super(node, state)
        end

        private

        def stem_notation(content)
          "_{#{content}}"
        end
      end

      Coradoc::Input::HTML::Converters.register :sub, Sub.new
    end
  end
end
