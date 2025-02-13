# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Dd < Stepmod::Utils::Converters::Base
        def to_coradoc(node, _state = {})
          "#{node.text}\n"
        end

        Coradoc::Input::HTML::Converters.register :dd, Dd.new
      end
    end
  end
end
