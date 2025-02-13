# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Sup < Coradoc::Input::HTML::Converters::Sup
        def to_coradoc(node, state = {})
          state[:equation] ? stem_notation(treat_children(node, state)) : super(node, state)
        end

        def stem_notation(content)
          "^{#{content}}"
        end
      end

      Coradoc::Input::HTML::Converters.register :sup, Sup.new
    end
  end
end
