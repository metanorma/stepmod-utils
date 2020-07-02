# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ClauseRef < ReverseAsciidoctor::Converters::Base
        def convert(node, _state = {})
          " term:[#{normalized_ref(node['linkend'])}] "
        end

        private

        def normalized_ref(ref)
          return unless ref || ref.empty?

          ref.to_s.split(':').last.squeeze(' ').strip
        end
      end
      ReverseAsciidoctor::Converters.register :clause_ref, ClauseRef.new
    end
  end
end