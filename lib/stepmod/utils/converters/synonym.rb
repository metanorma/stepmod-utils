# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Synonym < Stepmod::Utils::Converters::Base
        def to_coradoc(node, _state = {})
          "alt:[#{node.text.strip}]"
        end
      end

      Coradoc::Input::Html::Converters.register :synonym, Synonym.new
    end
  end
end
