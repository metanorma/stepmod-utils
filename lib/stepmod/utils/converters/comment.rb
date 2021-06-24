# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Comment < ReverseAdoc::Converters::Base
        def convert(node, _state = {})
          comment = node.text.strip.split("\n").map do |line|
            "\n// #{line}"
          end.join("\n")
          "#{comment}\n"
        end
      end

      ReverseAdoc::Converters.register :comment, Comment.new
    end
  end
end
