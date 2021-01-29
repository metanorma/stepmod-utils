module Stepmod
  module Utils
    module Converters
      class ExpressRefExpressDescription < ReverseAdoc::Converters::Base
        def convert(node, _state = {})
          parts = node['linkend'].to_s.split(':').last.split('.')
          "<<express_ref:#{parts.first}:#{parts.join('.')}, #{parts.last}>>"
        end
      end
      ReverseAdoc::Converters.register :express_ref, ExpressRefExpressDescription.new
    end
  end
end
