# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Ol < Coradoc::Input::HTML::Converters::Ol
        LIST_TAGS = ["ol", "ul", "dir"].freeze

        def to_coradoc(node, state = {})
          content = super(node, state)

          # Dont make early parse on nested lists
          LIST_TAGS.include?(node.parent.name) ? content : Coradoc::Generator.gen_adoc(content) + "\n"
        end
      end

      Ol::LIST_TAGS.each do |tag|
        Coradoc::Input::HTML::Converters.register tag.to_sym, Ol.new
      end
    end
  end
end
