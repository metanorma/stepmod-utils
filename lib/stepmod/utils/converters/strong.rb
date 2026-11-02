# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Strong < Stepmod::Utils::Converters::Base
        BLANK_CHARS = "{blank}"

        def to_coradoc(node, state = {})
          bold_converted(node, state)
        end

        # Wraps already converted +content+ in AsciiDoc bold markup, as
        # +node+ (a <b>, or an element standing in for one) would.
        def mark_up(node, content, state)
          return content if content.strip.empty? || state[:already_strong] ||
            state[:equation]

          strong_tag = unconstrained?(node, content, state) ? "**" : "*"
          leading = content[0, content.length - content.lstrip.length]
          trailing = content[content.rstrip.length..]
          handle_express_escape_seq(
            node,
            "#{leading}#{strong_tag}#{content.strip}#{strong_tag}#{trailing}",
          )
        end

        private

        # Constrained bold (`*x*`) is not recognised inside a word, so
        # unconstrained markup is needed whenever a word character touches it.
        def unconstrained?(node, content, state)
          return true if state[:non_flanking_whitesapce]

          (content.match?(/\A\S/) && word_sibling?(node.previous, /\w\z/)) ||
            (content.match?(/\S\z/) && word_sibling?(node.next, /\A\w/))
        end

        def word_sibling?(sibling, pattern)
          sibling&.text? && sibling.text.match?(pattern)
        end

        def bold_converted(node, state)
          cloned_node = node.clone
          equations = extract_equations(cloned_node)
          content = treat_children(cloned_node,
                                   state.merge(already_strong: true))
          equation_content = equations.map do |equation|
            treat(equation, state.merge(equation: true, already_strong: true))
          end

          content = if state[:equation] && state[:convert_bold_and_italics]
                      "bb(#{content.strip})"
                    else
                      mark_up(node, content, state)
                    end

          [content, equation_content].compact.join("")
        end

        def extract_equations(node)
          equations = []

          node.children.each do |n|
            next if n.name != "eqn"

            equations << n
            n.unlink
          end

          equations
        end

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
      end

      Coradoc::Input::Html::Converters.register :strong, Strong.new
      Coradoc::Input::Html::Converters.register :b,      Strong.new
    end
  end
end
