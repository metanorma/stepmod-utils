# frozen_string_literal: true

require "coradoc/input/html/converters/figure"

module Stepmod
  module Utils
    module Converters
      class Figure < Coradoc::Input::Html::Converters::Figure
        def self.pattern(state, id)
          if state[:schema_and_entity].nil?
            raise StandardError.new("[figure]: no state given, #{id}")
          end

          schema = state[:schema_and_entity].split(".").first
          "figure-#{schema}-#{id}"
        end

        def to_coradoc(node, state = {})
          # If we want to skip this node
          return "" if state[:no_notes_examples]

          # Set ID to "figure-id" in case of conflicts
          node["id"] = if node["id"]
                         self.class.pattern(state, node["id"])
                       else
                         self.class.pattern(state, node["number"])
                       end

          result = super(node, state)
          id = result.id
          anchor = "[[#{id}]]\n" if id
          padding = "\n====\n"
          child_content = treat_children(node, state).strip
          "\n\n#{anchor}.#{result.title}#{padding}#{child_content}#{padding}"
        end

        def extract_title(node)
          title = node.at("./title")
          return "" if title.nil?

          treat_children(title, {})
        end
      end

      # This replaces the converter
      Coradoc::Input::Html::Converters.register :figure, Figure.new
    end
  end
end
