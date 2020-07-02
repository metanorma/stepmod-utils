# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Synonym < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          "alt:[#{node.text}]\n"
        end
      end

      ReverseAsciidoctor::Converters.register :synonym, Synonym.new
    end
  end
end