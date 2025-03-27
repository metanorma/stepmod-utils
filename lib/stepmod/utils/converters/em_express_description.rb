# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Em < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          italic_converted(node, state)
        end

        def to_coradoc(node, state = {})
          italic_converted(node, state)
        end

        private

        def italic_converted(node, state)
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
