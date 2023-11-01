# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Strong < ReverseAdoc::Converters::Base
        BLANK_CHARS = "{blank}"

        def convert(node, state = {})
          content = treat_children(node, state.merge(already_strong: true))
          strong_tag = state[:non_flanking_whitesapce] ? '**' : '*'
          if content.strip.empty? || state[:already_strong] || content_is_equation?(content)
            content
          else
            handle_express_escape_seq(
              node,
              "#{content[/^\s*/]}#{strong_tag}#{content.strip}#{strong_tag}#{content[/\s*$/]}"
            )
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
          sibling&.text? && sibling.text =~ match
        end

        def content_is_equation?(content)
          content.match(/^\s*\[\[[^\]]*\]\]/) || content.match(/^\s*\[stem\]/)
        end
      end

      ReverseAdoc::Converters.register :strong, Strong.new
      ReverseAdoc::Converters.register :b,      Strong.new
    end
  end
end
