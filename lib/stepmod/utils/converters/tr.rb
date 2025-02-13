# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Tr < Coradoc::Input::HTML::Converters::Tr
        def to_coradoc(node, state = {})
          content = super(node, state)
          line_break = content.header ? "\n\n" : "\n"
          Coradoc::Generator.gen_adoc(content).rstrip + line_break
        end
      end

      Coradoc::Input::HTML::Converters.register :tr, Tr.new
    end
  end
end
