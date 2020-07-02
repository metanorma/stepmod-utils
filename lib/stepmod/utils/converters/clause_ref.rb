# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ClauseRef < ReverseAsciidoctor::Converters::Base
        def convert(node, _state = {})
          " term:[#{node['linkend']}] "
        end
      end
      ReverseAsciidoctor::Converters.register :clause_ref, ClauseRef.new
    end
  end
end