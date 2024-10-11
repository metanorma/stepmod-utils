require "stepmod/utils/change_edition"

module Stepmod
  module Utils
    class ChangeEditionCollection
      def initialize
        @collection = {}
      end

      def fetch_or_initialize(version)
        @collection[version] ||=
          Stepmod::Utils::ChangeEdition.new("version" => version)
      end

      def to_h
        @collection.values.map(&:to_h)
      end

      def []=(version, change_edition)
        klass = Stepmod::Utils::ChangeEdition
        @collection[version] = if change_edition.is_a?(klass)
                                 change_edition
                               else
                                 klass.new(change_edition)
                               end
      end

      def [](version)
        @collection[version]
      end

      def count
        @collection.values.count
      end
      alias_method :size, :count
    end
  end
end
