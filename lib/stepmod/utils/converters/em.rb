# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Em < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          content = treat_children(node, state.merge(already_italic: true))
          if content.strip.empty? || state[:already_italic]
            content
          else
            "#{content[/^\s*/]}_#{content.strip}_#{content[/\s*$/]}"
          end
        end
      end

      Coradoc::Input::HTML::Converters.register :em, Em.new
      Coradoc::Input::HTML::Converters.register :cite, Em.new
    end
  end
end
