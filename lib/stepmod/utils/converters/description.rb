# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Description < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          treat_children(node, state)
        end

        private

        def treat_children(node, state)
          res = node.children.map { |child| treat(child, state) }
          res.map(&:strip).reject(&:empty?).join("\n\n")
        end
      end

      Coradoc::Input::Html::Converters.register :description, Description.new
    end
  end
end
