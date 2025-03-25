# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Strong < Stepmod::Utils::Converters::Base
        BLANK_CHARS = "{blank}"

        def to_coradoc(node, state = {})
          bold_converted(node, state)
        end

        private

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
                    elsif content.strip.empty? || state[:already_strong] || state[:equation]
                      content
                    else
                      strong_tag = state[:non_flanking_whitesapce] ? "**" : "*"
                      handle_express_escape_seq(
                        node,
                        "#{content[/^\s*/]}#{strong_tag}#{content.strip}#{strong_tag}#{content[/\s*$/]}",
                      )
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
