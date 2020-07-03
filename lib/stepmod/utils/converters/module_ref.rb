# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ModuleRef < ReverseAsciidoctor::Converters::Base
        def convert(node, _state = {})
          ref = node['linkend']
          # #23:
          # In this case when we see this:

          # <module_ref linkend="product_as_individual:3_definition">individual products</module_ref>
          # We take the text value of the element and convert to this:

          # term:[individual products]
          if node['linkend'].split(':').length > 1
            ref = node.text
          end
          " term:[#{normalized_ref(ref)}] "
        end

        private

        def normalized_ref(ref)
          return unless ref || ref.empty?

          ref.squeeze(' ').strip
        end
      end
      ReverseAsciidoctor::Converters.register :module_ref, ModuleRef.new
    end
  end
end