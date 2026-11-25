# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Tr < Ceradoc::Html::Converters::Tr
        def to_coradoc(node, state = {})
          content = super(node, state)
          line_break = content.header ? "\n\n" : "\n"
          Stepmod::Utils::CeradocCompat.gen_adoc(content).rstrip + line_break
        end
      end

      Ceradoc::Html::Converters.register :tr, Tr.new
    end
  end
end
