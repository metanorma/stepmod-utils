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
      attr_reader :express_file, :resource_docs_cache, :stepmod_dir, :schema_name

      # @param express_file [String] path to the exp file needed to annotate
      # @param resource_docs_cache [String] output of ./stepmod-build-resource-docs-cache
      def initialize(express_file:, stepmod_dir: nil)
        @express_file = express_file
        @resource_docs_cache = resource_docs_schemas(stepmod_dir)
        @stepmod_dir = stepmod_dir || Dir.pwd
        @added_bibdata = {}
        @images_references = {}

        @schema_name = Expressir::Express::Parser.from_file(express_file)
                                                 .schemas
                                                 .first
                                                 .id
        @schema_name = normalize_schema_name(@schema_name)
        self
      end

      # Needed to fix scheme casing issues, e.g. xxx_LF => xxx_lf
      def normalize_schema_name(name)
        case name.downcase
        # module schemas have first letter capitalized, rest in lowercase
        when /_arm_lf\Z/i, /_mim_lf\Z/i, /_arm\Z/i, /_mim\Z/i
          name.downcase.capitalize
        # resource schemas are all in lowercase
        else
          name.downcase
        end
      end

      SCHEMA_VERSION_MATCH_REGEX = /^[[:space:]]*?SCHEMA [0-9a-zA-Z_]+;(?<trailing>.*)[[:space:]]*$/
      def is_missing_version(schema_content)
        m = schema_content.match(SCHEMA_VERSION_MATCH_REGEX)
        if m.nil?
          false
        elsif m[0] # match
          true
        else
          false
        end
      end

      def replace_schema_string_with_version(content)
        m = content.match(SCHEMA_VERSION_MATCH_REGEX)
        result = build_schema_string_with_version
        unless m["trailing"].nil?
          result = "#{result}#{m['trailing']}"
        end

        content.gsub!(SCHEMA_VERSION_MATCH_REGEX, result)
      end

      def build_schema_string_with_version
        # Geometric_tolerance_arm => geometric-tolarance-arm
        name_in_asn1 = @schema_name.downcase.gsub("_", "-")
        schema_type, type_number = case @schema_name.downcase
        when /_arm\Z/i
          [:module, 1]
        when /_mim\Z/i
          [:module, 2]
        when /_arm_lf\Z/i
          [:module, 3]
        when /_mim_lf\Z/i
          [:module, @module_has_arm_lf ? 4 : 3]
        else # any resource schema without version strings
          puts "[annotator-WARNING] this resource schema is missing a version string: #{@schema_name}"
          [:resource, 1]
        end

        # TODO there are schemas with only arm, arm_lf:
        # schemas/modules/reference_schema_for_sysml_mapping/arm_lf.exp
        # TODO there are schemas with only arm, mim, mim_lf:
        # schemas/modules/limited_length_or_area_indicator_assignment/mim_lf.exp
        part = @identifier.part
        edition = @identifier.edition
        schema_or_object = (schema_type == :module) ? "schema" : "object"

        "\nSCHEMA #{@schema_name} '{ " \
          "iso standard 10303 part(#{part}) " \
          "version(#{edition}) " \
          "#{schema_or_object}(1) " \
          "#{name_in_asn1}(#{type_number}) " \
        "}';\n"
      end

      def resource_docs_schemas(stepmod_dir)
        filepath = File.join(stepmod_dir, "data", "resource_docs", "*",
                             "resource.xml")

        schemas = {}
        Dir.glob(filepath).each do |resource_docs_file|
          match = resource_docs_file.match("data[/\]resource_docs[/\]([^/\]+)[/\]resource.xml")
          resource_docs_dir = match.captures[0]

          resource_docs = Nokogiri::XML(File.read(resource_docs_file)).root
          resource_docs.xpath("schema").each do |schema|
            schemas[schema["name"]] = resource_docs_dir
          end
        end

        schemas
      end

      def call
        match = File.basename(express_file).match('^(arm|mim|bom|arm_lf|mim_lf|DomainModel)\.exp$')
        descriptions_base = match ? "#{match.captures[0]}_descriptions.xml" : "descriptions.xml"

        descriptions_file = File.join(File.dirname(express_file),
                                      descriptions_base)

        output_express = File.read(express_file)
        converted_description = ""
        base_linked = ""
        processed_images_cache = {}

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

            schema_base_dir = resource_docs_cache[base_linked]
            add_images_references(converted_description, schema_base_dir,
                                  processed_images_cache)

            # Add converted description from exact linked path
            if resource_docs_dir && added_resource_descriptions[description["linkend"]].nil?
              output_express << convert_from_resource_file(resource_docs_dir,
                                                           stepmod_dir, description["linkend"], descriptions_file)
              added_resource_descriptions[description["linkend"]] = true
            end
          end
        end

        bib_file_name = extract_bib_file_name(match,
                                              resource_docs_cache[@schema_name || ""])
        bib_file = if match
                     File.join(File.dirname(express_file), bib_file_name)
                   else
                     resource_docs_file_path(stepmod_dir, bib_file_name)
                   end

        unless bib_file && File.exist?(bib_file)
          raise StandardError.new(
            "bib_file for #{schema_name} does not exist: #{bib_file}",
          )
        end

        output_express << prepend_bibdata(
          converted_description || "",
          # bib_file will not be present for resouces
          # that are not in resource_docs cache.
          # e.g hierarchy_schema
          bib_file,
          @schema_name,
          match,
        )

        if is_missing_version(output_express)
          puts "[annotator-WARNING] schema (#{@schema_name}) missing version string. "\
            "Adding: `#{build_schema_string_with_version}` to schema."

          output_express = replace_schema_string_with_version(output_express)
        end

        {
          annotated_text: sanitize(output_express),
          images_references: @images_references,
        }
      rescue StandardError => e
        puts "[ERROR]!!! #{e.message}"
        puts e.backtrace
      end

      private

      def sanitize(file_content)
        file_content
          .gsub("(*)", "(`*`)")
          .gsub(";;", ";")
      end

      def add_images_references(description, schema_base_dir,
processed_images_cache)
        referenced_images = description.scan(/image::(.*?)\[\]/).flatten

        referenced_images.each do |referenced_image|
          next unless schema_base_dir

          image_file_path = File.join("resource_docs", schema_base_dir,
                                      referenced_image)
          new_image_file_path = referenced_image

          if processed_images_cache[new_image_file_path]
            processed_images_cache[new_image_file_path] = true
            next
          end

          processed_images_cache[new_image_file_path] = true
          @images_references[image_file_path] = new_image_file_path
        end

        @images_references
      end

      def convert_from_description_text(descriptions_file, description)
        Dir.chdir(File.dirname(descriptions_file)) do
          wrapper = "<ext_descriptions>#{description}</ext_descriptions>"
          notes = description.xpath("note")
          examples = description.xpath("example")
          figures = description.xpath("figure")
          tables = description.xpath("table")

          converted_description = <<~DESCRIPTION

            #{Stepmod::Utils::SmrlDescriptionConverter.convert(
              wrapper,
              no_notes_examples: true,
              descriptions_file: descriptions_file,
            )}
          DESCRIPTION

          if description["linkend"].nil?
            raise StandardError.new("[stepmod-file-annotator] ERROR: no linkend for #{descriptions_file}!")
          end

          converted_figures = figures.map do |figure|
            Stepmod::Utils::Converters::ExpressFigure
              .new
              .convert(figure, schema_and_entity: description["linkend"], descriptions_file: descriptions_file)
          end.join

          converted_tables = tables.map do |table|
            Stepmod::Utils::Converters::ExpressTable
              .new
              .convert(table, schema_and_entity: description["linkend"], descriptions_file: descriptions_file)
          end.join

          converted_notes = notes.map do |note|
            Stepmod::Utils::Converters::ExpressNote
              .new
              .convert(note, schema_and_entity: description["linkend"], descriptions_file: descriptions_file)
          end.join

          converted_examples = examples.map do |example|
            Stepmod::Utils::Converters::ExpressExample
              .new
              .convert(example, schema_and_entity: description["linkend"], descriptions_file: descriptions_file)
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

        # for schema version string generation
        @identifier = bibdata[:identifier]

        return description.to_s if @added_bibdata[schema_and_entity]

        published_in = <<~PUBLISHED_IN

          (*"#{schema_and_entity}.__published_in"
          #{bibdata[:identifier].to_s(with_edition: true)}
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
        match && %w[arm mim arm_lf mim_lf].include?(match.captures[0])
      end

      def bom?(match)
        match && %w[bom DomainModel].include?(match.captures[0])
      end

      def extract_bib_file_name(match, default_file_name = "")
        return default_file_name || "" unless match

        if %w[arm mim arm_lf mim_lf].include?(match.captures[0])
          "module.xml"
        else
          "business_object_model.xml"
        end
      end

      def extract_bib_data(match, bib, schema_and_entity)
        # for schema version string generation
        @identifier = identifier(bib)

        return resource_bib_data(bib, schema_and_entity) unless match

        if module?(match)
          @module_has_arm = !bib.xpath("arm").first.nil?
          @module_has_mim = !bib.xpath("mim").first.nil?
          @module_has_arm_lf = !bib.xpath("arm_lf").first.nil?
          @module_has_mim_lf = !bib.xpath("mim_lf").first.nil?

          puts "[annotator] module has schemas: " \
            "ARM(#{@module_has_arm}) MIM(#{@module_has_mim}) " \
            "ARM_LF(#{@module_has_arm_lf}) MIM_LF(#{@module_has_mim_lf})"

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

        pubid = Pubid::Iso::Identifier.create(
          publisher: "ISO",
          number: 10303,
        )

        pubid.part = part if part && !part.empty?
        pubid.year = year.split("-").first if year && !year.empty?
        pubid.edition = edition if edition && !edition.empty?

        pubid
      end

      def resource_bib_data(bib, schema_and_entity)
        schema = bib.xpath("schema[@name='#{schema_and_entity}']").first

        {
          identifier: identifier(bib),
          edition: bib.attributes["version"],
          number: schema.attributes["number"],
          supersedes_concept: schema.attributes["number.supersedes"],
          status: bib.attributes["status"],
          title: bib.attributes["title"] || bib.attributes["name"],
        }
      end

      def module_bib_data(bib, type)
        {
          identifier: identifier(bib),
          edition: bib.attributes["version"],
          number: bib.attributes["wg.number.#{type}"],
          supersedes_concept: bib.attributes["wg.number.#{type}.supersedes"],
          status: bib.attributes["status"],
          title: bib.attributes["title"] || bib.attributes["name"],
        }
      end

      def bom_bib_data(bib)
        {
          identifier: identifier(bib),
          edition: bib.attributes["version"],
          number: bib.attributes["wg.number.bom.exp"],
          supersedes_concept: bib.attributes["wg.number.bom.supersedes"],
          status: bib.attributes["status"],
          title: bib.attributes["title"] || bib.attributes["name"],
        }
      end

      def convert_from_resource_file(resource_docs_dir, stepmod_dir, linked,
descriptions_file)
        resource_docs_file = resource_docs_file_path(stepmod_dir,
                                                     resource_docs_dir)

        resource_docs = Nokogiri::XML(File.read(resource_docs_file)).root
        schema = resource_docs.xpath("schema[@name='#{linked}']")

        Dir.chdir(File.dirname(descriptions_file)) do
          wrapper = "<resource>#{schema}</resource>"

          "\n" + Stepmod::Utils::SmrlResourceConverter.convert(
            wrapper,
            {
              no_notes_examples: false,
              schema_and_entity: linked,
              descriptions_file: descriptions_file,
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
