module Stepmod
  module Utils
    class ChangeEdition
      attr_accessor :version, :description
      attr_reader :additions, :modifications, :deletions

      def initialize(options)
        @version = options[:version]
        @description = options[:description]
        self.additions = options[:additions]
        self.modifications = options[:modifications]
        self.deletions = options[:deletions]
      end

      def additions=(additions)
        validate_type("additions", additions, Array)

        @additions = additions
      end

      def modifications=(modifications)
        validate_type("modifications", modifications, Array)

        @modifications = modifications
      end

      def deletions=(deletions)
        validate_type("deletions", deletions, Array)

        @deletions = deletions
      end

      def to_h
        {
          "version" => version,
          "description" => description,
          "additions" => additions,
          "modifications" => modifications,
          "deletions" => deletions,
        }
      end

      private

      def validate_type(column, value, type)
        raise "#{column} must be of type ::#{type}" unless value.is_a?(type)
      end
    end
  end
end
