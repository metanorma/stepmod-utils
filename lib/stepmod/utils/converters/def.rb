module Stepmod
  module Utils
    module Converters
      class Def < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          node = node.dup
          "#{additional_block(node)}#{treat_children(node, state)}"
        end

        private

        def treat_children(node, state)
          converted = node.children.each_with_object({}) do |child, res|
            content = treat(child, state)
            next if content.strip.empty?

            res[child] = content
          end
          previous = nil
          result = ""

          converted.each.with_index do |(child, content), _i|
            result += if block_tag?(child, previous)
                        "\n\n"
                      elsif comment_tag?(child, previous)
                        "\n"
                      else
                        " "
                      end
            result += content
            previous = child
          end

          # Remove double newlines for every line
          result = result.gsub(/\n\n+/, "\n\n")
          result = result.squeeze(" ")

          result.strip
        end

        def block_tag?(child, previous)
          %w[ul example note alt p].include?(child.name) ||
            (previous && %w[ul example note alt p].include?(previous.name))
        end

        def comment_tag?(child, previous)
          child.name == "comment" || (previous && previous.name === "comment")
        end

        def additional_block(node)
          # Treat first `p` tag as an `alt` block, metanorma/stepmod-utils#9
          first_child_tag = node
            .children
            .find { |n| n.is_a?(Nokogiri::XML::Element) }
          return unless can_transform_to_alt?(first_child_tag)

          result = Stepmod::Utils::Converters::Synonym
            .new
            .convert(first_child_tag)

          first_child_tag.remove
          "#{result}\n\n"
        end

        # metanorma/stepmod-utils#18 when para is the only text doe snot transform it
        def can_transform_to_alt?(first_child_tag)
          return false unless first_child_tag&.name == "p" &&
            defined?(Stepmod::Utils::Converters::Synonym)

          next_sibling = first_child_tag.next
          while next_sibling
            return true if !next_sibling.text.to_s.strip.empty? && %w[p
                                                                      text].include?(next_sibling.name)

            next_sibling = next_sibling.next
          end
          false
        end
      end

      ReverseAdoc::Converters.register :def, Def.new
      ReverseAdoc::Converters.register :description, Def.new
    end
  end
end
