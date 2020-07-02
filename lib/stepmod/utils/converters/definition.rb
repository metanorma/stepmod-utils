# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Definition < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          treat_children(node, state)
        end
      end

      ReverseAsciidoctor::Converters.register :definition, Definition.new
    end
  end
end
