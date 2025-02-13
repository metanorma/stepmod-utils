# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Comment < Stepmod::Utils::Converters::Base
        def to_coradoc(node, _state = {})
          comment = node.text.strip.split("\n").map do |line|
            "\n// #{line}"
          end.join("\n")
          "#{comment}\n"
        end
      end

      Coradoc::Input::HTML::Converters.register :comment, Comment.new
    end
  end
end
