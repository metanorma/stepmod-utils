require "json"
require "stepmod/utils/smrl_description_converter"
require "stepmod/utils/smrl_resource_converter"
require "stepmod/utils/converters/express_note"
require "stepmod/utils/converters/express_example"
require "stepmod/utils/converters/express_figure"
require "stepmod/utils/converters/express_table"

module Stepmod
  module Utils
    class StepmodFileAnnotator
      attr_reader :express_file, :resource_docs_cache_file, :stepmod_dir

      # @param express_file [String] path to the exp file needed to annotate
      # @param resource_docs_cache_file [String] output of ./stepmod-build-resource-docs-cache
      def initialize(express_file:, resource_docs_cache_file:, stepmod_dir: nil)
        @express_file = express_file
        @resource_docs_cache_file = resource_docs_cache_file
        @stepmod_dir = stepmod_dir || Dir.pwd
      end

      def call
        match = File.basename(express_file).match('^(arm|mim|bom)\.exp$')
        descriptions_base = match ? "#{match.captures[0]}_descriptions.xml" : "descriptions.xml"
        descriptions_file = File.join(File.dirname(express_file),
                                      descriptions_base)
        output_express = File.read(express_file)
        resource_docs_cache = JSON.parse(File.read(resource_docs_cache_file))

        if File.exists?(descriptions_file)
          descriptions = Nokogiri::XML(File.read(descriptions_file)).root
          added_resource_descriptions = {}
          descriptions.xpath("ext_description").each do |description|
            # Add base resource from linked path if exists, eg "language_schema.language.wr:WR1" -> "language_schema"
            base_linked = description["linkend"].to_s.split(".").first
            if added_resource_descriptions[base_linked].nil?
              base_reource_doc_dir = resource_docs_cache[description["linkend"].to_s.split(".").first]
              if base_reource_doc_dir
                output_express << convert_from_resource_file(
                  base_reource_doc_dir, stepmod_dir, base_linked, descriptions_file
                )
              end
              added_resource_descriptions[base_linked] = true
            end
            resource_docs_dir = resource_docs_cache[description["linkend"]]
            # Convert content description
            # when a schema description is available from resource.xml and also descriptions.xml, the description from resource.xml is only used.
            # https://github.com/metanorma/annotated-express/issues/32#issuecomment-792609078
            if description.text.strip.length.positive? && resource_docs_dir.nil?
              output_express << convert_from_description_text(
                descriptions_file, description
              )
            end
            # Add converted description from exact linked path
            if resource_docs_dir && added_resource_descriptions[description["linkend"]].nil?
              output_express << convert_from_resource_file(resource_docs_dir,
                                                           stepmod_dir, description["linkend"], descriptions_file)
              added_resource_descriptions[description["linkend"]] = true
            end
          end
        end

        output_express
      end

      private

      def convert_from_description_text(descriptions_file, description)
        Dir.chdir(File.dirname(descriptions_file)) do
          wrapper = "<ext_descriptions>#{description}</ext_descriptions>"
          notes = description.xpath("note")
          examples = description.xpath("example")
          figures = description.xpath("figure")
          tables = description.xpath("table")

          converted_description = <<~DESCRIPTION

            #{Stepmod::Utils::SmrlDescriptionConverter.convert(wrapper, no_notes_examples: true)}
          DESCRIPTION

          if description["linkend"].nil?
            raise StandardError.new("[stepmod-file-annotator] ERROR: no linkend for #{descriptions_file}!")
          end

          converted_figures = figures.map do |figure|
            Stepmod::Utils::Converters::ExpressFigure
              .new
              .convert(figure, schema_and_entity: description["linkend"])
          end.join

          converted_tables = tables.map do |table|
            Stepmod::Utils::Converters::ExpressTable
              .new
              .convert(table, schema_and_entity: description["linkend"])
          end.join

          converted_notes = notes.map do |note|
            Stepmod::Utils::Converters::ExpressNote
              .new
              .convert(note, schema_and_entity: description["linkend"])
          end.join

          converted_examples = examples.map do |example|
            Stepmod::Utils::Converters::ExpressExample
              .new
              .convert(example, schema_and_entity: description["linkend"])
          end.join

          [
            converted_description,
            converted_figures,
            converted_tables,
            converted_examples,
            converted_notes,
          ].join("")
        end
      end

      def convert_from_resource_file(resource_docs_dir, stepmod_dir, linked, descriptions_file)
        resource_docs_file = File.join(stepmod_dir, "data/resource_docs",
                                       resource_docs_dir, "resource.xml")
        # puts(resource_docs_file)
        resource_docs = Nokogiri::XML(File.read(resource_docs_file)).root
        schema = resource_docs.xpath("schema[@name='#{linked}']")

        Dir.chdir(File.dirname(descriptions_file)) do
          wrapper = "<resource>#{schema}</resource>"

          "\n" + Stepmod::Utils::SmrlResourceConverter.convert(
            wrapper,
            {
              no_notes_examples: false,
              schema_and_entity: linked
            }
          )
        end
      end
    end
  end
end
