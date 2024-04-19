require "psych"
require "stepmod/utils/change_edition"
require "stepmod/utils/change_edition_collection"

module Stepmod
  module Utils
    class Change
      attr_accessor :schema_name, :mapping_table
      attr_reader :change_editions

      MODULE_TYPES = {
        arm: "arm",
        mim: "mim",
        arm_longform: "arm_lf",
        mim_longform: "mim_lf",
        mapping: "mapping",
        changes: "changes",
        mapping_table: "mapping",
      }.freeze

      TYPES_WITHOUT_EXTENSION = %w[
        changes
        mapping_table
      ].freeze

      def initialize(stepmod_dir:, schema_name:, type:)
        @stepmod_dir = stepmod_dir
        @change_editions = Stepmod::Utils::ChangeEditionCollection.new
        @mapping_table = {}
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
        change_hash = if @type == "mapping_table"
                        @mapping_table
                      else
                        to_h
                      end
        return if change_hash.empty?

        File.write(filepath(@type), Psych.dump(stringify_keys(change_hash)))
      end

      def to_h
        change_editions_list = change_editions.to_h

        return {} if change_editions_list.empty?

        {
          "schema" => schema_name,
          "change_edition" => change_editions_list,
        }
      end

      private

      def filepath(type)
        File.join(
          @stepmod_dir,
          "data",
          base_folder,
          schema_name,
          filename(type),
        )
      end

      def filename(type)
        return "#{MODULE_TYPES[type.to_sym]}.yaml" if TYPES_WITHOUT_EXTENSION.include?(type.to_s)

        "#{MODULE_TYPES[type.to_sym] || schema_name}.changes.yaml"
      end

      def base_folder
        if resource?
          "resources"
        else
          "modules"
        end
      end

      # Hash#transform_keys is not available in Ruby 2.4
      # so we have to do this ourselves :(
      # symbolize hash keys
      def stringify_keys(hash)
        result = {}
        hash.each_pair do |key, value|
          result[key.to_s] = if value.is_a?(Hash)
                               stringify_keys(value)
                             elsif value.is_a?(Array)
                               value.map { |v| stringify_keys(v) }
                             else
                               value
                             end
        end
        result
      end
    end
  end
end
