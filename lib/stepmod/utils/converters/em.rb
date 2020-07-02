# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Em < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          content = treat_children(node, state.merge(already_italic: true))
          if content.strip.empty? || state[:already_italic]
            content
          else
            "#{content[/^\s*/]}_#{content.strip}_#{content[/\s*$/]}"
          end
        end
      end

      ReverseAsciidoctor::Converters.register :em, Em.new
      ReverseAsciidoctor::Converters.register :cite,  Em.new
    end
  end
end
