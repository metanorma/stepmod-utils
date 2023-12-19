# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Drop < Stepmod::Utils::Converters::Base
        def convert(_node, _state = {})
          ""
        end
      end

      ReverseAdoc::Converters.register :caption, Drop.new
      ReverseAdoc::Converters.register :figcaption, Drop.new
      ReverseAdoc::Converters.register :title, Drop.new
      ReverseAdoc::Converters.register :link, Drop.new
      ReverseAdoc::Converters.register :style, Drop.new
      ReverseAdoc::Converters.register :meta, Drop.new
      ReverseAdoc::Converters.register :script, Drop.new
      ReverseAdoc::Converters.register :comment, Drop.new
    end
  end
end
