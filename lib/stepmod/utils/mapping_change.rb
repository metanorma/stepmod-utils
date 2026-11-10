require "stepmod/utils/change"

module Stepmod
  module Utils
    class MappingChange < Change
      ATTRIBUTES = %i[change description].freeze

      attr_accessor(*ATTRIBUTES)

      def initialize(change: nil, description: nil)
        super()
        @change = change
        @description = description
      end
    end
  end
end
