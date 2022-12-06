require "nokogiri"
require "stepmod/utils/change_collection"
require "stepmod/utils/smrl_description_converter"

module Stepmod
  module Utils
    class ChangesExtractor
      MODULE_TYPES = %w[arm mim arm_longform mim_longform].freeze

      attr_accessor :stepmod_dir

      def self.call(stepmod_dir:, stdout: $stdout)
        new(stepmod_dir: stepmod_dir, stdout: stdout).call
      end

      def initialize(stepmod_dir:, stdout: $stdout)
        @stdout = stdout
        @stepmod_dir = stepmod_dir
        @collection = Stepmod::Utils::ChangeCollection.new(
          stepmod_dir: stepmod_dir,
        )
      end

      def call
        all_resource_changes_files.each do |resource_change_file|
          xml_changes = Nokogiri::XML(File.read(resource_change_file)).root
          add_resource_changes_to_collection(xml_changes, @collection)
        end

        all_modules_changes_files.each do |module_change_file|
          xml_changes = Nokogiri::XML(File.read(module_change_file)).root
          schema_name = module_change_file.split("/")[-2]
          add_module_changes_to_collection(xml_changes, @collection, schema_name)
        end

        @collection
      end

      private

      # rubocop:disable Metrics/MethodLength
      def add_resource_changes_to_collection(xml_data, collection)
        xml_data.xpath("//changes").each do |changes_node|
          changes_node.xpath("change_edition").each do |change_edition_node|
            options = {
              version: change_edition_node.attr("version"),
              description: Stepmod::Utils::SmrlDescriptionConverter.convert(
                change_edition_node.at("description"),
              ),
            }

            add_change(
              collection,
              change_edition_node,
              options,
              type: "schema",
            )
          end
        end
      end

      def add_module_changes_to_collection(xml_data, collection, schema_name)
        xml_data.xpath("//changes").each do |changes_node|
          changes_node.xpath("change").each do |change_node|
            options = {
              schema_name: schema_name,
              version: change_node.attr("version"),
              description: Stepmod::Utils::SmrlDescriptionConverter.convert(
                change_node.at("description"),
              ),
            }

            MODULE_TYPES.each do |type|
              add_change(
                collection,
                change_node,
                options,
                type: type,
              )
            end
          end
        end
      end

      def add_change(collection, change_node, options, type:)
        change_node.xpath("#{type}.changes").each do |changes|
          schema_name = options[:schema_name] || changes.attr("schema_name")
          schema_name = correct_schema_name(schema_name)
          change = collection.fetch_or_initialize(schema_name, type: type)

          change_edition = extract_change_edition(changes, options)
          change.add_change_edition(change_edition)
        end
      end

      def extract_change_edition(schema_changes, options)
        type = options[:type] || "schema"
        addition_nodes = schema_changes.xpath("#{type}.additions")
        modification_nodes = schema_changes.xpath("#{type}.modifications")
        deletion_nodes = schema_changes.xpath("#{type}.deletions")

        {
          type: type,
          version: options[:version],
          description: options[:description],
          additions: extract_modified_objects(addition_nodes),
          modifications: extract_modified_objects(modification_nodes),
          deletions: extract_modified_objects(deletion_nodes),
        }
      end
      # rubocop:enable Metrics/MethodLength

      def extract_modified_objects(nodes)
        nodes.map do |node|
          node.xpath("modified.object").map do |object|
            {
              type: object.attr("type"),
              name: object.attr("name"),
              interfaced_items: object.attr("interfaced.items"),
            }.compact
          end
        end.flatten
      end

      def all_resource_changes_files
        Dir.glob(File.join(stepmod_dir, "data/resource_docs/*/resource.xml"))
      end

      def all_modules_changes_files
        Dir.glob(File.join(stepmod_dir, "data/modules/*/module.xml"))
      end

      # rubocop:disable Layout/LineLength
      def correct_schema_name(schema_name)
        schema_name_corrector = {
          "material_property_definition" => "material_property_definition_schema",
          "qualified_measure" => "qualified_measure_schema",
          "material_property_representation" => "material_property_representation_schema",
          "annotated_3d_model_data_quality_criteria" => "annotated_3d_model_data_quality_criteria_schema",
        }

        schema_name_corrector[schema_name] || schema_name
      end
      # rubocop:enable Layout/LineLength
    end
  end
end
