require "stepmod/utils/change"

module Stepmod
  module Utils
    class ChangeCollection
      def initialize(stepmod_dir:)
        @stepmod_dir = stepmod_dir
        @changes = {}
      end

      def fetch_or_initialize(change, type)
        schema = schema_name(change)

        @changes[schema_identifier(schema, type)] ||= Change.new(
          type: type,
          stepmod_dir: @stepmod_dir,
          schema_name: schema,
        )
      end

      def fetch(change, type)
        schema = schema_name(change)
        @changes[schema_identifier(schema, type)]
      end

      def save_to_files
        @changes.each_value(&:save_to_file)
      end

      def count
        @changes.keys.count
      end
      alias_method :size, :count

      def each(&block)
        @changes.values.each(&block)
      end

      private

      def schema_name(change)
        change.is_a?(Stepmod::Utils::Change) ? change.schema_name : change
      end

      def schema_identifier(schema_name, type)
        "#{schema_name}_#{type}"
      end
    end
  end
end
