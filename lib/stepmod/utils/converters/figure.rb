# frozen_string_literal: true

require "reverse_adoc/converters/figure"

module Stepmod
  module Utils
    module Converters
      class Figure < ReverseAdoc::Converters::Figure
        def self.pattern(state, id)
          if state[:schema_and_entity].nil?
            raise StandardError.new("[figure]: no state given, #{id}")
          end

          schema = state[:schema_and_entity].split(".").first
          "figure-#{schema}-#{id}"
        end

        def convert(node, state = {})
          # If we want to skip this node
          return "" if state[:no_notes_examples]

          # Set ID to "figure-id" in case of conflicts
          node['id'] = if node['id']
            self.class.pattern(state, node['id'])
          else
            self.class.pattern(state, node['number'])
          end

          super(node, state)
        end
      end

      # This replaces the converter
      ReverseAdoc::Converters.register :figure, Figure.new
    end
  end
end
