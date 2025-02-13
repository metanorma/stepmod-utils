module Stepmod
  module Utils
    module Converters
      class ExpressRefExpressDescription < Stepmod::Utils::Converters::Base
        def to_coradoc(node, _state = {})
          parts = node["linkend"].to_s.split(":").last.split(".")
          "<<express:#{parts.join('.').strip},#{parts.last.strip}>>"
        end
      end
      Coradoc::Input::HTML::Converters.register :express_ref, ExpressRefExpressDescription.new
    end
  end
end
