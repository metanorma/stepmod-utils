# frozen_string_literal: true

require "stepmod/utils/html_to_asciimath"

module Stepmod
  module Utils
    module Converters
      class Eqn < ReverseAdoc::Converters::Base
        TAGS_NOT_IN_CONTEXT = %w[b i].freeze

        def convert(node, state = {})
          cloned_node = node.clone
          if definition_node?(cloned_node)
            return definition_converted(cloned_node, state)
          end

          stem_converted(cloned_node, state)
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
                                                               state))}\n"
        end

        def stem_converted(cloned_node, state)
          remove_tags_not_in_context(cloned_node)
          internal_content = treat_children(cloned_node, state)
          content = Stepmod::Utils::HtmlToAsciimath.new.call(internal_content)
          res = <<~TEMPLATE

            [stem]
            ++++
            #{remove_trash_symbols(content.strip)}
            ++++

          TEMPLATE
          res = "[[#{cloned_node['id']}]]\n#{res}" if cloned_node["id"]&.length&.positive?
          res
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
      end

      ReverseAdoc::Converters.register :eqn, Eqn.new
    end
  end
end
