
module Stepmod
  module Utils
    module Converters
      class Def < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          node = node.dup
          "#{additional_block(node)}#{treat_children(node, state)}"
        end

        private

        def treat_children(node, state)
          converted = node.children.each_with_object({}) do |child, res|
                        content = treat(child, state).strip
                        next if content.empty?

                        res[child] = content
                      end
          previous = nil
          result = ''
          converted.each.with_index do |(child, content), i|
            if i == 0 || inlinde_tag?(child, previous)
              result += " #{content}"
            else
              result += "\n\n#{content}"
            end
            previous = child
          end
          result.strip
        end

        def inlinde_tag?(child, previous)
          %w[text sub i clause_ref].include?(child.name) && previous && %w[i sub text clause_ref].include?(previous.name)
        end

        def additional_block(node)
          # Treat first `p` tag as an `alt` block, metanorma/stepmod-utils#9
          first_child_tag = node
                              .children
                              .find { |n| n.is_a?(Nokogiri::XML::Element) }
          return unless first_child_tag&.name == 'p' &&
                          defined?(Stepmod::Utils::Converters::Synonym)

          result = Stepmod::Utils::Converters::Synonym
                    .new
                    .convert(first_child_tag)
          first_child_tag.remove
          "#{result}\n\n"
        end
      end

      ReverseAsciidoctor::Converters.register :def, Def.new
    end
  end
end
