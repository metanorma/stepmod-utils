# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Stem < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          " stem:[#{node.text.strip}] "
        end
      end

      ReverseAsciidoctor::Converters.register :i, Stem.new
    end
  end
end
