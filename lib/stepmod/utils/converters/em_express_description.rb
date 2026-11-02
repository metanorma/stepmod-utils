# frozen_string_literal: true

require_relative "strong"

module Stepmod
  module Utils
    module Converters
      class Em < Stepmod::Utils::Converters::Base
        BOLD_TAGS = %w[b strong].freeze

        def convert(node, state = {})
          italic_converted(node, state)
        end

        def to_coradoc(node, state = {})
          italic_converted(node, state)
        end

        private

        def italic_converted(node, state)
          bold = sole_bold_child(node)
          if bold && !state[:already_italic]
            return bold_italic(node, bold, state)
          end

          cloned_node = node.clone
          equations = extract_equations(cloned_node)
          content = treat_children(cloned_node,
                                   state.merge(already_italic: true))
          equation_content = equations.map do |equation|
            treat(equation, state.merge(equation: true, already_italic: true))
          end

          content = if state[:equation] && state[:convert_bold_and_italics]
                      "ii(#{content.strip})"
                    elsif content.strip.empty? || state[:already_italic] || state[:equation]
                      content
                    else
                      "#{content[/^\s*/]}_#{content.strip}_#{content[/\s*$/]}"
                    end

          [content, equation_content].compact.join("")
        end

        # <i><b>x</b></i> is written bold outside, italic inside: `*_x_*`.
        def bold_italic(node, bold, state)
          content = treat_children(bold, state.merge(already_italic: true))
          return content if content.strip.empty?

          lead = content[/^\s*/]
          trail = content[/\s*$/]
          Strong.new.mark_up(node, "#{lead}_#{content.strip}_#{trail}", state)
        end

        def sole_bold_child(node)
          return unless node.element_children.one?
          return if node.children.any? { |c| c.text? && !c.text.strip.empty? }

          bold = node.element_children.first
          return unless BOLD_TAGS.include?(bold.name)

          bold unless bold.element_children.any? { |c| c.name == "eqn" }
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
      end

      Coradoc::Input::Html::Converters.register :i, Em.new
    end
  end
end
