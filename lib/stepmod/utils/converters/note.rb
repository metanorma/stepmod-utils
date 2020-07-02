# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Note < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          <<~TEMPLATE
            [NOTE]
            --
            #{treat_children(node, state).strip}
            --
          TEMPLATE
        end
      end
      ReverseAsciidoctor::Converters.register :note, Note.new
    end
  end
end