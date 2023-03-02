require "json"
require "stepmod/utils/smrl_description_converter"
require "stepmod/utils/smrl_resource_converter"
require "stepmod/utils/converters/express_note"
require "stepmod/utils/converters/express_example"
require "stepmod/utils/converters/express_figure"
require "stepmod/utils/converters/express_table"
require "expressir"
require "expressir/express/parser"
require "pubid-iso"

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
        @added_bibdata = {}

        @schema_name = Expressir::Express::Parser.from_file(express_file)
                                                 .schemas
                                                 .first
                                                 .id
      end

      def call
        match = File.basename(express_file).match('^(arm|mim|bom)\.exp$')
        descriptions_base = match ? "#{match.captures[0]}_descriptions.xml" : "descriptions.xml"

        descriptions_file = File.join(File.dirname(express_file),
                                      descriptions_base)

        output_express = File.read(express_file)
        converted_description = ""
        base_linked = ""

        if File.exist?(descriptions_file)
          descriptions = Nokogiri::XML(File.read(descriptions_file)).root
          added_resource_descriptions = {}

          descriptions.xpath("ext_description").each do |description|
            # Add base resource from linked path if exists, eg "language_schema.language.wr:WR1" -> "language_schema"
            base_linked = description["linkend"].to_s.split(".").first

            if added_resource_descriptions[base_linked].nil?
              base_reource_doc_dir = resource_docs_cache[description["linkend"].to_s.split(".").first]
              if base_reource_doc_dir
                converted_description << convert_from_resource_file(
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
              converted_description << convert_from_description_text(
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

        bib_file_name = extract_bib_file_name(match, resource_docs_cache[@schema_name || ""])
        bib_file = if match
                     File.join(File.dirname(express_file), bib_file_name)
                   else
                     resource_docs_file_path(stepmod_dir, bib_file_name)
                   end

        output_express << if bib_file && File.exist?(bib_file)
                            prepend_bibdata(
                              converted_description || "",
                              # bib_file will not be present for resouces
                              # that are not in resource_docs cache.
                              # e.g hierarchy_schema
                              bib_file,
                              @schema_name,
                              match,
                            )
                          else
                            converted_description
                          end

        sanitize(output_express)
      rescue StandardError => e
        puts "[ERROR]!!! #{e.message}"
        puts e.backtrace
      end

      private

      def sanitize(file_content)
        file_content.gsub("(*)", "(`*`)")
      end

      def resource_docs_cache
        @resource_docs_cache ||= JSON.parse(File.read(resource_docs_cache_file))
      end

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

      def prepend_bibdata(description, bibdata_file, schema_and_entity, match)
        bib = Nokogiri::XML(File.read(bibdata_file)).root
        bibdata = extract_bib_data(match, bib, schema_and_entity)

        return description.to_s if @added_bibdata[schema_and_entity]

        published_in = <<~PUBLISHED_IN

          (*"#{schema_and_entity}.__published_in"
          #{bibdata[:identifier]}
          *)
        PUBLISHED_IN

        identifier = <<~IDENTIFIER if bibdata[:number]
          (*"#{schema_and_entity}.__identifier"
          ISO/TC 184/SC 4/WG 12 N#{bibdata[:number]}
          *)
        IDENTIFIER

        supersedes = <<~SUPERSEDES if bibdata[:supersedes_concept]
          (*"#{schema_and_entity}.__supersedes"
          ISO/TC 184/SC 4/WG 12 N#{bibdata[:supersedes_concept]}
          *)
        SUPERSEDES

        status = <<~STATUS if bibdata[:status]
          (*"#{schema_and_entity}.__status"
          #{bibdata[:status]}
          *)
        STATUS

        title = <<~TITLE if bibdata[:title]
          (*"#{schema_and_entity}.__title"
          #{bibdata[:title]}
          *)
        TITLE

        document = <<~DOCUMENT if bibdata_file
          (*"#{schema_and_entity}.__schema_file"
          #{Pathname(bibdata_file).relative_path_from(@stepmod_dir)}
          *)
        DOCUMENT

        @added_bibdata[schema_and_entity] = true

        [
          published_in,
          identifier,
          supersedes,
          status,
          title,
          description,
          document,
        ].compact.join("\n")
      end

      def module?(match)
        match && %w[arm mim].include?(match.captures[0])
      end

      def bom?(match)
        match && %w[bom].include?(match.captures[0])
      end

      def extract_bib_file_name(match, default_file_name = "")
        return default_file_name || "" unless match

        if %w[arm mim].include?(match.captures[0])
          "module.xml"
        else
          "business_object_model.xml"
        end
      end

      def extract_bib_data(match, bib, schema_and_entity)
        return resource_bib_data(bib, schema_and_entity) unless match

        if module?(match)
          module_bib_data(bib, match.captures[0])
        elsif bom?(match)
          bom_bib_data(bib)
        end
      end

      def identifier(bib)
        part = bib.attributes["part"].value
        year = bib.attributes["publication.year"].value

        # year="tbd" in data/modules/geometric_tolerance/module.xml and
        # probabaly in some other places as well
        year = "" if year == "tbd"
        edition = bib.attributes["version"].value

        pubid = Pubid::Iso::Identifier.new(
          publisher: "ISO",
          number: 10303,
        )

        pubid.part = part if part && !part.empty?
        pubid.year = year.split("-").first if year && !year.empty?
        pubid.edition = edition if edition && !edition.empty?

        pubid.to_s(with_edition: true)
      end

      def resource_bib_data(bib, schema_and_entity)
        schema = bib.xpath("schema[@name='#{schema_and_entity}']").first

        {
          identifier: identifier(bib),
          number: schema.attributes["number"],
          supersedes_concept: schema.attributes["number.supersedes"],
          status: bib.attributes["status"],
          title: bib.attributes["title"] || bib.attributes["name"],
        }
      end

      def module_bib_data(bib, type)
        {
          identifier: identifier(bib),
          number: bib.attributes["wg.number.#{type}"],
          supersedes_concept: bib.attributes["wg.number.#{type}.supersedes"],
          status: bib.attributes["status"],
          title: bib.attributes["title"] || bib.attributes["name"],
        }
      end

      def bom_bib_data(bib)
        {
          identifier: identifier(bib),
          number: bib.attributes["wg.number.bom.exp"],
          supersedes_concept: bib.attributes["wg.number.bom.supersedes"],
          status: bib.attributes["status"],
          title: bib.attributes["title"] || bib.attributes["name"],
        }
      end

      def convert_from_resource_file(resource_docs_dir, stepmod_dir, linked, descriptions_file)
        resource_docs_file = resource_docs_file_path(stepmod_dir, resource_docs_dir)

        resource_docs = Nokogiri::XML(File.read(resource_docs_file)).root
        schema = resource_docs.xpath("schema[@name='#{linked}']")

        Dir.chdir(File.dirname(descriptions_file)) do
          wrapper = "<resource>#{schema}</resource>"

          "\n" + Stepmod::Utils::SmrlResourceConverter.convert(
            wrapper,
            {
              no_notes_examples: false,
              schema_and_entity: linked,
            },
          )
        end
      end

      def resource_docs_file_path(stepmod_dir, resource_docs_dir)
        File.join(
          stepmod_dir,
          "data/resource_docs",
          resource_docs_dir,
          "resource.xml",
        )
      end
    end
  end
end
