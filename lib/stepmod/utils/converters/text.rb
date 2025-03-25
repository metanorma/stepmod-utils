# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Text < Coradoc::Input::Html::Converters::Text
        def to_coradoc(node, state = {})
          if node.text.strip.empty?
            treat_empty(node, state)
          else
            treat_text(node, state)
          end
        end

        private

        def treat_text(node, state)
          text = node.text
          text = preserve_nbsp(text)
          text = remove_inner_newlines(text)
          text = remove_border_newlines(text)

          text = preserve_keychars_within_backticks(text)

          text = preserve_pipes_within_tables(text, state)
          text = wrap_if_contains_spaces(text, state)
          preserve_tags(text, state)
        end

        def preserve_nbsp(text)
          text.gsub(/\u00A0/, "&nbsp;")
        end

        def preserve_tags(text, state)
          return text if state[:inside_table]

          text.gsub(/[<>]/, ">" => '\>', "<" => '\<')
        end

        def remove_border_newlines(text)
          text.gsub(/\A\n+/, "").gsub(/\n+\z/, "")
        end

        def wrap_if_contains_spaces(text, state)
          return "(#{text})" if state[:equation] && text.strip.match?(/\s/) && text.match?(/^[A-Za-z ]+$/)

          text
        end

        def remove_inner_newlines(text)
          text.tr("\n\t", " ").squeeze(" ")
        end

        def preserve_keychars_within_backticks(text)
          text.gsub(/`.*?`/) do |match|
            match.gsub('\_', "_").gsub('\*', "*")
          end
        end

        def preserve_pipes_within_tables(text, state)
          return text unless state[:inside_table]

          text.gsub("|", "\\|")
        end
      end

      Coradoc::Input::Html::Converters.register :text, Text.new
    end
  end
end
