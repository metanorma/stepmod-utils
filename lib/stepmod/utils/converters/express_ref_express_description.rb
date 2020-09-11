# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExpressRefExpressDescription < ReverseAdoc::Converters::Base
        def convert(node, _state = {})
          "express_ref:[#{node['linkend'].to_s.split(':').last}]"
        end
      end
      ReverseAdoc::Converters.register :express_ref, ExpressRefExpressDescription.new
    end
  end
end
