# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Strong < ReverseAdoc::Converters::Base
        BLANK_CHARS = "{blank}".freeze

        def convert(node, state = {})
          content = treat_children(node, state.merge(already_strong: true))
          if content.strip.empty? || state[:already_strong]
            content
          else
            handle_express_escape_seq(node, "#{content[/^\s*/]}*#{content.strip}*#{content[/\s*$/]}")
          end
        end

        private

        def handle_express_escape_seq(node, content)
          res = content
          if braces_sibling?(node.previous, true)
            res = "#{BLANK_CHARS}#{res}"
          end
          if braces_sibling?(node.next)
            res = "#{res}#{BLANK_CHARS}"
          end
          res
        end

        def braces_sibling?(sibling, end_of_text = false)
          match = end_of_text ? /\($/ : /^\)/
          sibling && sibling.text? && sibling.text =~ match
        end
      end

      ReverseAdoc::Converters.register :strong, Strong.new
      ReverseAdoc::Converters.register :b,      Strong.new
    end
  end
end