# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ModuleRef < ReverseAdoc::Converters::Base
        def convert(node, _state = {})
          ref = node["linkend"]
          # #23:
          # In this case when we see this:

          # <module_ref linkend="product_as_individual:3_definition">individual products</module_ref>
          # We take the text value of the element and convert to this:

          # {{individual products}}

          ref = node.text.strip
          if !ref.empty?
            " {{#{normalized_ref(ref)}}} "
          elsif
            ref = node["linkend"].split(":").first
            " *#{ref}*"
          end
        end

        private

        def normalized_ref(ref)
          return unless ref || ref.empty?

          ref.squeeze(" ").strip
        end
      end
      ReverseAdoc::Converters.register :module_ref, ModuleRef.new
    end
  end
end
