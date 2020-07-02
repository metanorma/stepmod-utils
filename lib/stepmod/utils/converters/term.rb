# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Term < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          "\n=== #{treat_children(node, state)}\n"
        end
      end

      ReverseAsciidoctor::Converters.register :term, Term.new
    end
  end
end