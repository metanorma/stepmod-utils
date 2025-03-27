# frozen_string_literal: true

require "stepmod/utils/html_to_asciimath"
require "stepmod/utils/equation_logger"

module Stepmod
  module Utils
    module Converters
      class Eqn < Stepmod::Utils::Converters::Base
        TAGS_NOT_IN_CONTEXT = %w[b i].freeze

        def to_coradoc(node, state = {})
          cloned_node = node.clone
          if definition_node?(cloned_node)
            return definition_converted(cloned_node, state)
          end

          equation_converted = stem_converted(cloned_node, state)

          log_equation(node, state, equation_converted)

          equation_converted
        end

        private

        def definition_node?(node)
          first_strong_node = node
                              .children
                              .find do |n|
            return false if !n.text? && n.name != "b"

            n.name == "b"
          end
          first_strong_node&.next &&
            first_strong_node.next.text? &&
            first_strong_node.next.content =~ /\s+:/
        end

        def definition_converted(cloned_node, state)
          first_strong_node = cloned_node
                              .children
                              .find do |n|
            return false if !n.text? && n.name != "b"

            n.name == "b"
          end
          first_strong_node.next.content = first_strong_node.next.content.gsub(
            /\s?:/, ""
          )
          term = first_strong_node.text.strip
          first_strong_node.remove
          "\n\n#{term}:: #{remove_trash_symbols(treat_children(cloned_node,
                                                               state.merge(equation: true)))}\n"
        end

        def stem_converted(cloned_node, state)
          remove_tags_not_in_context(cloned_node) unless state[:convert_bold_and_italics]
          internal_content = treat_children(cloned_node,
                                            state.merge(equation: true))
          content = Stepmod::Utils::HtmlToAsciimath.new.call(internal_content)
          res = <<~TEMPLATE
            #{source_type_comment(cloned_node)}
            [stem]
            ++++
            #{remove_trash_symbols(content.strip)}
            ++++


          TEMPLATE
          res = "[[#{cloned_node['id']}]]\n#{res}" if cloned_node["id"]&.length&.positive?
          res
        end

        def source_type_comment(node)
          "\n// source type is bigeqn\n" if node.name == "bigeqn"
        end

        def remove_trash_symbols(content)
          content
            .gsub(/ /, "")
            .strip
            .gsub(/\(\d\)$/, "")
            .gsub(/\b(\w*?_+\w+)\b/, '"\1"')
            .gsub(/([^\s])\s+_{/, '\1_{')
            .strip
        end

        # Remove all tags that make no sense in equations, eg: strong, italic
        # Search for such tags, move their children into the root
        # context and remove them
        def remove_tags_not_in_context(node)
          TAGS_NOT_IN_CONTEXT.each do |tag_name|
            node
              .children
              .each do |n|
                remove_tags_not_in_context(n) if n.children.length.positive?
                next if n.name != tag_name

                n.add_previous_sibling(n.children)
                n.unlink
              end
          end
        end

        def equation_logger
          @equation_logger ||= Stepmod::Utils::EquationLogger.new
        end

        def log_equation(node, state, equation_converted)
          equation_converted_with_bold_and_italics = stem_converted(node.clone,
                                                                    state.merge(convert_bold_and_italics: true))

          return if equation_converted_with_bold_and_italics == equation_converted

          equation_logger.anchor = state[:schema_and_entity] || state[:schema_name]
          equation_logger.document = state[:descriptions_file]
          equation_logger.equation = node.to_s
          equation_logger.equation_converted = equation_converted
          equation_logger.equation_converted_with_bold_and_italics = equation_converted_with_bold_and_italics

          equation_logger.log
        end
      end

      Coradoc::Input::Html::Converters.register :eqn, Eqn.new
      Coradoc::Input::Html::Converters.register :bigeqn, Eqn.new
    end
  end
end
