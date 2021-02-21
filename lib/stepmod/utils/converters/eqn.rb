# frozen_string_literal: true

require 'stepmod/utils/html_to_asciimath'

module Stepmod
  module Utils
    module Converters
      class Eqn < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          internal_content = treat_children(node, state)
          content = Stepmod::Utils::HtmlToAsciimath.new.call(internal_content)
          <<~TEMPLATE
          [stem]
          ++++
          #{content}
          ++++
          TEMPLATE
        end
      end

      ReverseAdoc::Converters.register :eqn, Em.new
    end
  end
end
