require "stepmod/utils/change"

module Stepmod
  module Utils
    class SchemaChange < Change
      ATTRIBUTES = %i[type name description interfaced_items].freeze

      attr_accessor(*ATTRIBUTES)

      def initialize(type:, name:, description: nil, interfaced_items: nil)
        super()
        @type = type
        @name = name
        @description = description
        @interfaced_items = interfaced_items
      end
    end
  end
end
