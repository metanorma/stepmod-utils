# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Li < Coradoc::Input::HTML::Converters::Li
        def to_coradoc(node, state = {})
          li = super
          li.content = li.content.map{|content|
            parsed_content = Coradoc::Generator.gen_adoc(content)
            whitespace_preserve = parsed_content[0] == " "
            whitespace_preserve ? parsed_content : parsed_content.lstrip
          }
          li
        end
      end

      Coradoc::Input::HTML::Converters.register :li, Li.new
    end
  end
end
