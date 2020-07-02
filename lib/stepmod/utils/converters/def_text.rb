module Stepmod
  module Utils
    module Converters
      class DefText < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          if node.text.strip.empty?
            treat_empty(node, state)
          else
            treat_text(node)
          end
        end

        private

        def treat_empty(node, state)
          parent = node.parent.name.to_sym
          if [:ol, :ul].include?(parent)  # Otherwise the identation is broken
            ''
          elsif state[:tdsinglepara]
            ''
          elsif node.text == ' '          # Regular whitespace text node
            ' '
          else
            ''
          end
        end

        def treat_text(node)
          text = node.text
          text = preserve_nbsp(text)
          text = escape_keychars(text)
          text = preserve_keychars_within_backticks(text)
          text = preserve_tags(text)
          text = compact_whitespace(text)

          text
        end

        def compact_whitespace(text)
          text
            .gsub(/[[:blank:]]+/, ' ')
            .gsub(/\A(\n)?[[:blank:]]|[[:blank:]]\z/, '')
            .gsub(/(?<!\A)\s+(?!\Z)/, ' ')
            .squeeze(' ')
        end

        def preserve_nbsp(text)
          text.gsub(/\u00A0/, "&nbsp;")
        end

        def preserve_tags(text)
          text.gsub(/[<>]/, '>' => '\>', '<' => '\<')
        end

        def preserve_keychars_within_backticks(text)
          text.gsub(/`.*?`/) do |match|
            match.gsub('\_', '_').gsub('\*', '*')
          end
        end
      end

      ReverseAsciidoctor::Converters.register :def_text, DefText.new
    end
  end
end