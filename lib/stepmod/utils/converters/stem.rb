# frozen_string_literal: true

require 'stepmod/utils/converters/em'

module Stepmod
  module Utils
    module Converters
      class Stem < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          return Em.new.convert(node, state) if node.text.strip.length > 8

          " stem:[#{node.text.strip}] "
        end
      end

      ReverseAdoc::Converters.register :i, Stem.new
    end
  end
end
