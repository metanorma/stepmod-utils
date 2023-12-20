# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Blockquote < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          id = node["id"]
          anchor = id ? "[[#{id}]]\n" : ""
          cite = node["cite"]
          attrs = cite ? "[quote, #{cite}]\n" : ""
          content = treat_children(node, state).strip
          content = ReverseAdoc.cleaner.remove_newlines(content)
          # "\n\n> " << content.lines.to_a.join('> ') << "\n\n"
          "\n\n#{attrs}____\n" << content.lines.to_a.join("") << "\n____\n\n"
        end
      end

      ReverseAdoc::Converters.register :blockquote, Blockquote.new
    end
  end
end
