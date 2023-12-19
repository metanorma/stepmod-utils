# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Ignore < Stepmod::Utils::Converters::Base
        def convert(_node, _state = {})
          "" # noop
        end
      end

      ReverseAdoc::Converters.register :colgroup, Ignore.new
      ReverseAdoc::Converters.register :col,      Ignore.new
    end
  end
end
