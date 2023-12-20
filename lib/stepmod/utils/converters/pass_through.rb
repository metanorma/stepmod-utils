# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class PassThrough < Stepmod::Utils::Converters::Base
        def convert(node, _state = {})
          node.to_s
        end
      end
    end
  end
end
