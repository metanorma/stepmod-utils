require "psych"
require "stepmod/utils/change_edition"

module Stepmod
  module Utils
    class Change
      attr_accessor :schema_name, :resource
      attr_reader :change_editions

      TYPES = {
        arm: "arm",
        mim: "mim",
        arm_longform: "arm_lf",
        mim_longform: "mim_lf",
      }.freeze

      def initialize(stepmod_dir:, schema_name:, type:, resource:)
        @stepmod_dir = stepmod_dir
        @change_editions = {}
        @resource = resource
        @schema_name = schema_name
        @type = type
      end

      def resource?
        !!@resource
      end

      def module?
        !resource?
      end

      def add_change_edition(change_edition)
        version = change_edition[:version]
        change_edition = Stepmod::Utils::ChangeEdition.new(change_edition)

        @change_editions[version] = change_edition
      end

      def save_to_file
        File.write(filepath(@type), Psych.dump(to_h))
      end

      def to_h
        {
          "schema" => schema_name,
          "change_edition" => change_editions.values.map(&:to_h),
        }
      end

      private

      def filepath(type)
        File.join(
          @stepmod_dir,
          "data",
          base_folder,
          schema_name,
          "#{TYPES[type.to_sym] || schema_name}.changes.yaml",
        )
      end

      def base_folder
        if resource?
          "resources"
        else
          "modules"
        end
      end
    end
  end
end
