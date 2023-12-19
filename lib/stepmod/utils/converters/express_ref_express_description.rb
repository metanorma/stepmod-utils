module Stepmod
  module Utils
    module Converters
      class ExpressRefExpressDescription < Stepmod::Utils::Converters::Base
        def convert(node, _state = {})
          parts = node["linkend"].to_s.split(":").last.split(".")
          "<<express:#{parts.join('.').strip},#{parts.last.strip}>>"
        end
      end
      ReverseAdoc::Converters.register :express_ref,
                                       ExpressRefExpressDescription.new
    end
  end
end
