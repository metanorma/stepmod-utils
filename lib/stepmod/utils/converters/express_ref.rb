# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExpressRef < ReverseAsciidoctor::Converters::Base
        def convert(node, _state = {})
          "*#{node['linkend'].to_s.split('.').last}*"
        end
      end
      ReverseAsciidoctor::Converters.register :express_ref, ExpressRef.new
    end
  end
end