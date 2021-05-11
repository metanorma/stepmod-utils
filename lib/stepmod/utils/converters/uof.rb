# frozen_string_literal: true

require 'stepmod/utils/converters/synonym'

module Stepmod
  module Utils
    module Converters
      class Uof < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          <<~TEXT
          === #{node['name'].strip}

          <STEP module> #{treat_children(node, state).strip}
          TEXT
        end
      end

      ReverseAdoc::Converters.register :uof, Uof.new
    end
  end
end