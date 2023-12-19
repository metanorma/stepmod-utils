# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class P < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          id = node["id"]
          anchor = id ? "[[#{id}]]\n" : ""
          if state[:tdsinglepara]
            "#{anchor}#{treat_children(node, state).strip}"
          else
            "\n\n#{anchor}#{treat_children(node, state).strip}\n\n"
          end
        end
      end

      ReverseAdoc::Converters.register :p, P.new
    end
  end
end
