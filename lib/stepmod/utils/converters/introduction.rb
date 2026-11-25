# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Introduction < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          treat_children(node, state)
        end
      end

      Ceradoc::Html::Converters.register :introduction, Introduction.new
    end
  end
end
