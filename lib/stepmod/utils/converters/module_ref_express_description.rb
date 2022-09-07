module Stepmod
  module Utils
    module Converters
      class ModuleRefExpressDescription < ReverseAdoc::Converters::Base
        def convert(node, _state = {})
          parts = node["linkend"].to_s.split(":").last.split(".")
          "<<express:#{parts.join('.').strip},#{parts.last.strip}>>"
        end
      end
      ReverseAdoc::Converters.register :module_ref,
                                       ModuleRefExpressDescription.new
    end
  end
end
