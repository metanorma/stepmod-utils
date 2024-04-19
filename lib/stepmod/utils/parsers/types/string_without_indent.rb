# frozen_striing_literal: true

module Stepmod
  module Utils
    module Parsers
      module Types
        class StringWithoutIndent < Shale::Type::Value
          def self.cast(value)
            return unless value

            value.split("\n").map(&:strip).join("\n")
          end
        end
      end
    end
  end
end
