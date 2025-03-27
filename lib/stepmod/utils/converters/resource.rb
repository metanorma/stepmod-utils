# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Resource < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          treat_children(node, state)
        end
      end
      Coradoc::Input::Html::Converters.register :resource, Resource.new
    end
  end
end
