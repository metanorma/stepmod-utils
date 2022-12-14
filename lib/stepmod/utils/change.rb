require "psych"
require "stepmod/utils/change_edition"
require "stepmod/utils/change_edition_collection"

module Stepmod
  module Utils
    class Change
      attr_accessor :schema_name
      attr_reader :change_editions

      MODULE_TYPES = {
        arm: "arm",
        mim: "mim",
        arm_longform: "arm_lf",
        mim_longform: "mim_lf",
      }.freeze

      def initialize(stepmod_dir:, schema_name:, type:)
        @stepmod_dir = stepmod_dir
        @change_editions = Stepmod::Utils::ChangeEditionCollection.new
        @schema_name = schema_name
        @type = type
      end

      def resource?
        !module?
      end

      def module?
        MODULE_TYPES.key?(@type.to_sym) || MODULE_TYPES.value?(@type.to_s)
      end

      def add_change_edition(change_edition)
        @change_editions[change_edition[:version]] = change_edition
      end

      def fetch_change_edition(version)
        @change_editions[version]
      end
      alias_method :[], :fetch_change_edition

      def save_to_file
        File.write(filepath(@type), Psych.dump(to_h))
      end

      def to_h
        {
          "schema" => schema_name,
          "change_edition" => change_editions.to_h,
        }
      end

      private

      def filepath(type)
        File.join(
          @stepmod_dir,
          "data",
          base_folder,
          schema_name,
          "#{MODULE_TYPES[type.to_sym] || schema_name}.changes.yaml",
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
