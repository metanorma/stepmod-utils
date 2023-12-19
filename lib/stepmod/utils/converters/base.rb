require "reverse_adoc"

module Stepmod
  module Utils
    module Converters
      class Base < ReverseAdoc::Converters::Base
        PREFIXES_REGEX = /([Ff]ormula|[Ff]igure|[Tt]able)\s*/.freeze

        def treat_children(node, state)
          updated_node = remove_prefixes(node)

          updated_node.children.inject("") do |memo, child|
            memo << treat(child, state)
          end
        end

        private

        def remove_prefixes(node)
          node.children.each_with_index do |child, index|
            if child.text.match(PREFIXES_REGEX) && node.children[index + 1]&.name == "a"
              child.content = child.content.gsub(PREFIXES_REGEX, "")
            end
          end

          node
        end
      end
    end
  end
end
