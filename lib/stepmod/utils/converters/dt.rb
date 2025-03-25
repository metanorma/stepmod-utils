# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Dt < Stepmod::Utils::Converters::Base
        def to_coradoc(node, _state = {})
          return "\n\n{blank}::" if node.text.strip.empty?

          "\n\n#{node.text}:: "
        end

        Coradoc::Input::Html::Converters.register :dt, Dt.new
      end
    end
  end
end
