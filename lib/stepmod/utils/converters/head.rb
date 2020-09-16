# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Head < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          title = extract_title(node)
          "= #{title}\n:stem:\n\n"
        end

        def extract_title(node)
          title = node.at("./title")
          return "(???)" if title.nil?
          title.text
        end
      end

      ReverseAdoc::Converters.register :head, Head.new
    end
  end
end