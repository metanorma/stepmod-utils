# frozen_string_literal: true

require "coradoc/input/html/converters/figure"

module Stepmod
  module Utils
    module Converters
      class Figure < Coradoc::Input::HTML::Converters::Figure
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
          anchor = id ? "[[#{id}]]\n" : ""
          "\n\n#{anchor}.#{result.title}\n====\n" << treat_children(node,
                                                                    state).strip << "\n====\n\n"
        end

        def extract_title(node)
          title = node.at("./title")
          return "" if title.nil?

          treat_children(title, {})
        end
      end

      # This replaces the converter
      Coradoc::Input::HTML::Converters.register :figure, Figure.new
    end
  end
end
