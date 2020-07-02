# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ModuleRef < ReverseAsciidoctor::Converters::Base
        def convert(node, _state = {})
          " term:[#{node['linkend']}] "
        end
      end
      ReverseAsciidoctor::Converters.register :module_ref, ModuleRef.new
    end
  end
end