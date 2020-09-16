# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExpressG < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          node.children.map do |child|
            next unless child.name == 'imgfile'

            "expg_image:#{child['file']}[]"
          end.join("\n")
        end
      end

      ReverseAdoc::Converters.register 'express-g', ExpressG.new
    end
  end
end
