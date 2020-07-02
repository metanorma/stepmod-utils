# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Example < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          <<~TEMPLATE
            [example]
            ====
            #{treat_children(node, state).strip}
            ====
          TEMPLATE
        end
      end
      ReverseAsciidoctor::Converters.register :example, Example.new
    end
  end
end