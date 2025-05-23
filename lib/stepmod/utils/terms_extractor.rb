require "stepmod/utils/stepmod_definition_converter"
require "stepmod/utils/express_bibdata"
require "stepmod/utils/concept"
require "glossarist"
require "securerandom"
require "expressir"
require "expressir/express/parser"
require "indefinite_article"
require "pubid-iso"

Coradoc::Input::Html.config.unknown_tags = :bypass

module Stepmod
  module Utils
    class TermsExtractor
      # TODO: we may want a command line option to override this in the future
      ACCEPTED_STAGES = %w(IS DIS FDIS TS).freeze
      WITHDRAWN_STATUS = "withdrawn".freeze
      REDUNDENT_NOTE_REGEX = /^An? .*? is a type of \{\{[^}]*\}\}\s*?\.?$/.freeze

      attr_reader :stepmod_path,
                  :stepmod_dir,
                  :index_path,
                  :general_concepts,
                  :resource_concepts,
                  :parsed_bibliography,
                  :encountered_terms,
                  :part_concepts,
                  :part_resources,
                  :part_modules,
                  :stdout,
                  :git_rev

      def self.call(stepmod_dir, index_path, stdout = $stdout)
        new(stepmod_dir, index_path, stdout).call
      end

      def initialize(stepmod_dir, index_path, stdout)
        @stdout = stdout
        @stepmod_dir = stepmod_dir
        @stepmod_path = Pathname.new(stepmod_dir).realpath
        @index_path = Pathname.new(index_path).to_s
        @general_concepts = Glossarist::ManagedConceptCollection.new
        @resource_concepts = Glossarist::ManagedConceptCollection.new
        @parsed_bibliography = []
        @added_bibdata = {}
        @part_concepts = []
        @part_resources = {}
        @part_modules = {}
        @encountered_terms = {}
        @sequence = 0
      end

      def log(message)
        stdout.puts "[stepmod-utils] #{message}"
      end

      def term_special_category(bibdata)
        case bibdata.part.to_i
        when 41, 42, 43, 44, 45, 46, 47, 51
          true
        when [56..112]
          true
        else
          false
        end
      end

      def published_part_numbers
        docs_xml = Nokogiri::XML(File.read(@stepmod_path.join("library/docs.xml")))
        docs_xml.xpath("//doc").map do |x|
          x["part"]
        end.uniq.sort
      end

      def call
        log "INFO: STEPmod directory set to #{stepmod_dir}."
        log "INFO: Detecting paths..."

        log "INFO: Detecting Git SHA..."
        Dir.chdir(stepmod_path) do
          @git_rev = `git rev-parse HEAD` || nil
        end

        published_part_nos = published_part_numbers
        repo_index = Nokogiri::XML(File.read(@index_path)).root

        files = []

        # add module paths
        repo_index.xpath("//module").each do |x|
          unless published_part_nos.include? x["part"]
            log "INFO: skipping module #{x['name']} as part #{x['part']} is not published in `docs.xml`."
            next
          end

          if x["status"] == WITHDRAWN_STATUS
            log "INFO: skipping module #{x['name']} as it is withdrawn."
            next
          end

          arm_path = @stepmod_path.join("modules/#{x['name']}/arm_annotated.exp")
          mim_path = @stepmod_path.join("modules/#{x['name']}/mim_annotated.exp")

          if File.exist? arm_path
            files << arm_path
          else
            log "INFO: skipping module ARM for #{x['name']} as it does not exist at #{arm_path}."
          end

          if File.exist? mim_path
            files << mim_path
          else
            log "INFO: skipping module MIM for #{x['name']} as it does not exist at #{mim_path}."
          end
        end

        # Should ignore these because the `<resource_docs>` elements do not provide any EXPRESS schemas
        # # add resource_docs paths
        # repo_index.xpath("//resource_doc").each do |x|
        #   next if x['status'] == WITHDRAWN_STATUS

        #   path = Pathname.new("#{stepmod_dir}/resource_docs/#{x['name']}/resource.xml")
        #   files << path if File.exists? path
        # end

        # add resource paths
        repo_index.xpath("//resource").each do |x|
          unless published_part_nos.include? x["part"]
            log "INFO: skipping resource #{x['name']} as part #{x['part']} is not published in `docs.xml`."
            next
          end

          if x["status"] == WITHDRAWN_STATUS
            log "INFO: skipping resource #{x['name']} as it is withdrawn."
            next
          end

          if x["name"] == "iso13584_expressions_schema"
            log "INFO: skipping resource #{x['name']} as the ISO 13584 series is out of scope."
            next
          end

          if x["name"] == "iso13584_generic_expressions_schema"
            log "INFO: skipping resource #{x['name']} as the ISO 13584 series is out of scope."
            next
          end

          path = @stepmod_path.join("resources/#{x['name']}/#{x['name']}_annotated.exp")
          if File.exist? path
            files << path
          else
            log "INFO: skipping resource #{x['name']} as it does not exist at #{path}."
          end
        end

        # Should ignore these because we are skiping Clause 3 terms
        # add business_object_models paths
        # repo_index.xpath("//business_object_model").each do |x|
        #   next if x['status'] == WITHDRAWN_STATUS

        #   annotated_path = Pathname.new("#{stepmod_dir}/business_object_models/#{x['name']}/bom_annotated.exp")
        #   path = Pathname.new("#{stepmod_dir}/business_object_models/#{x['name']}/bom.exp")
        #   files << if File.exists?(annotated_path)
        #              annotated_path
        #            elsif File.exists?(path)
        #              path
        #            end
        # end

        # Should ignore these because there are no EXPRESS schemas here (they are implemented inside modules
        # # add application_protocols paths
        # repo_index.xpath("//application_protocol").each do |x|
        #   next if x['status'] == WITHDRAWN_STATUS

        #   path = Pathname.new("#{stepmod_dir}/application_protocols/#{x['name']}/application_protocol.xml")
        #   files << path if File.exists? path
        # end

        files.compact.sort!.uniq!
        process_term_files(files)

        [
          general_concepts, # Should be empty because skiping all Clause 3 terms
          resource_concepts,
          parsed_bibliography,
          part_concepts, # Should be empty because skiping all Clause 3 terms
          part_resources.values.compact,
          part_modules.values.compact,
        ]
      end

      private

      def process_term_files(files)
        repo = Expressir::Express::Parser.from_files(files)

        repo.schemas.each do |schema|
          parsed_schema_names = {}

          schema_name = schema.id
          file_path = schema.file
          type = extract_file_type(file_path)

          if parsed_schema_names[schema_name]
            log <<~ERROR.gsub("\n", " ")
              ERROR: We have encountered this schema before: #{schema_name} from
              path #{parsed_schema_names[schema_name]}, now at #{schema.file}
            ERROR

            next
          else
            parsed_schema_names[schema_name] = file_path
          end

          log "INFO: Processing schema: #{schema.id}"

          begin
            bibdata = Stepmod::Utils::ExpressBibdata.new(schema: schema)
          rescue StandardError => e
            log e
            log "ERROR: while processing bibdata for `#{schema_name}`"

            next
          end

          unless ACCEPTED_STAGES.include? bibdata.doctype
            log "INFO: skipped #{bibdata.doctype} as it is not " \
                "one of (#{ACCEPTED_STAGES.join(', ')})."
            next
          end

          if bibdata.part.to_s.empty?
            log "FATAL: missing `part` attribute: #{file_path}"
            log "INFO:  skipped #{schema.id} as it is missing `part` attribute."
            next
          end

          case type
          when "module_arm"
            parse_annotated_module(
              schema: schema,
              bibdata: bibdata,
              # See: metanorma/iso-10303-2#90
              domain_prefix: "application module",
              schema_type: type,
            )
          when "module_mim"
            parse_annotated_module(
              schema: schema,
              bibdata: bibdata,
              # See: metanorma/iso-10303-2#90
              domain_prefix: "application module",
              schema_type: type,
            )
          when "resource"
            parse_annotated_resource(schema: schema, bibdata: bibdata)
          end
        end
      end

      def extract_file_type(filename)
        match = filename.match(/(arm|mim|bom)_annotated\.exp$/)
        return "resource" unless match

        {
          "arm" => "module_arm",
          "mim" => "module_mim",
          "bom" => "business_object_model",
        }[match.captures[0]] || "resource"
      end

      def parse_annotated_module(schema:, bibdata:, domain_prefix:,
schema_type:)
        log "INFO: parse_annotated_module: " \
            "Processing modules schema #{schema.file}"

        collection = Glossarist::ManagedConceptCollection.new

        schema.entities.each do |entity|
          @sequence += 1
          document = entity.find("__schema_file")&.remarks&.first

          concept = generate_concept_from_entity(
            entity: entity,
            domain: "#{domain_prefix}: #{schema.id}",
            schema: {
              "name" => schema.id,
              "type" => "module",
              "path" => extract_file_path(entity.parent.file),
              "schema_type" => schema_type,
            },
            document: {
              "type" => "module",
              "module" => document && document.split("/")[-2],
              "path" => document,
            },
            bibdata: bibdata,
          )

          next unless concept

          find_or_initialize_concept(collection, concept)
        end

        if collection.to_a.size.positive?
          part_index = domain_prefix == "application module" ? 1 : 2
          part_modules[bibdata.part] ||= [bibdata, {}, {}]
          part_modules[bibdata.part][part_index][schema.id] = collection
        end

        if collection && !@added_bibdata[bibdata.part]
          parsed_bibliography << bibdata
          @added_bibdata[bibdata.part] = true
        end

        collection
      end

      def parse_annotated_resource(schema:, bibdata:)
        log "INFO: parse_annotated_resource: " \
            "Processing resources schema #{schema.file}"

        schema.entities.each do |entity|
          @sequence += 1
          log "INFO:   Processing entity: #{entity.id}"

          document = entity.find("__schema_file")&.remarks&.first

          concept = generate_concept_from_entity(
            entity: entity,
            domain: "resource: #{schema.id}",
            schema: {
              "name" => schema.id,
              "type" => "resource",
              "path" => extract_file_path(entity.parent.file),
              "schema_type" => "resource",
            },
            document: {
              "type" => "resource",
              "resource" => document && document.split("/")[-2],
              "path" => document,
            },
            bibdata: bibdata,
          )

          next unless concept

          if term_special_category(bibdata)
            part_resources[bibdata.part] ||= [
              bibdata,
              Glossarist::ManagedConceptCollection.new,
            ]
            # log "INFO: this part is special"
            find_or_initialize_concept(part_resources[bibdata.part][1], concept)
          else
            # log "INFO: this part is generic"
            find_or_initialize_concept(resource_concepts, concept)
          end

          unless @added_bibdata[bibdata.part]
            parsed_bibliography << bibdata
            @added_bibdata[bibdata.part] = true
          end
        end
      end

      # rubocop:disable Metrics/MethodLength
      def generate_concept_from_entity(entity:, schema:, domain:, bibdata:,
document:)
        old_definition = trim_definition(entity.remarks.first)
        schema_type = schema["schema_type"]
        definition = generate_entity_definition(entity, domain, schema_type)

        notes = [old_definition].reject { |note| redundant_note?(note) }

        Stepmod::Utils::Concept.from_yaml({
          data: {
            terms: [
              {
                "type" => "expression",
                "normative_status" => "preferred",
                "designation" => entity.id,
              },
            ],
            domain: domain,
            notes: notes.map { |note| { "content" => note } },
            definition: [{ "content" => definition.strip }],
            language_code: "eng",
            id: "#{bibdata.part}-#{@sequence}",
          },
          id: "#{bibdata.part}-#{@sequence}",
          sources: [
            {
              "type" => "authoritative",
              "ref" => bibdata.docid,

              # TODO: Commenting out link right now since it's not needed.
              # GitHub: metanorma/iso-10303-2#286
              #
              # "link" => "https://www.iso.org/standard/32858.html",
            },
          ],
          language_code: "eng",
          part: bibdata.part,
          schema: schema,
          document: document,
        }.to_yaml)
      end
      # rubocop:enable Metrics/MethodLength

      def extract_file_path(file_path)
        Pathname
          .new(file_path)
          .realpath
          .relative_path_from(stepmod_path)
          .to_s
      end

      def find_or_initialize_concept(collection, localized_concept)
        concept = collection.fetch_or_initialize(localized_concept.id)
        concept.add_l10n(localized_concept)
      end

      # rubocop:disable Metrics/MethodLength
      def combine_paragraphs(full_paragraph, next_paragraph)
        # If full_paragraph already contains a period, extract that.
        if m = full_paragraph.match(/\A(?<inner_first>[^\n]*?\.)\s/)
          # puts "CONDITION 1"
          if m[:inner_first]
            return m[:inner_first]
          else
            return full_paragraph
          end
        end

        # If full_paragraph ends with a period, this is the last.
        if /\.\s*\Z/.match?(full_paragraph)
          # puts "CONDITION 2"
          return full_paragraph
        end

        # If next_paragraph is a list
        if next_paragraph.start_with?("*")
          # puts "CONDITION 3"
          return "#{full_paragraph}\n\n#{next_paragraph}"
        end

        # If next_paragraph is a continuation of a list
        if next_paragraph.start_with?("which", "that")
          # puts "CONDITION 4"
          return "#{full_paragraph}\n\n#{next_paragraph}"
        end

        # puts "CONDITION 5"
        full_paragraph
      end

      def trim_definition(definition)
        return nil if definition.nil? || definition.empty?

        # Unless the first paragraph ends with "between" and is followed by a
        # list, don't split
        paragraphs = definition.split("\n\n")

        # puts paragraphs.inspect

        first_paragraph = paragraphs.first

        combined = if paragraphs.length > 1
                     paragraphs[1..-1].inject(first_paragraph) do |acc, p|
                       combine_paragraphs(acc, p)
                     end
                   else
                     combine_paragraphs(first_paragraph, "")
                   end

        # puts "combined--------- #{combined}"

        # Remove comments until end of line
        combined = "#{combined}\n"
        combined.gsub!(/\n\/\/.*?\n/, "\n")
        combined.strip!

        express_reference_to_mention(combined)

        # combined
        # # TODO: If the definition contains a list immediately after
        # # the first paragraph, don't split
        # return definition if definition =~ /\n\* /

        # unless (
        #   first_paragraph =~ /between:?\s*\Z/ ||
        #   first_paragraph =~ /include:?\s*\Z/ ||
        #   first_paragraph =~ /of:?\s*\Z/ ||
        #   first_paragraph =~ /[:;]\s*\Z/
        #   ) &&
        #   definition =~ /\n\n\*/

        #   # Only taking the first paragraph of the definition
        #   first_paragraph
        # end
      end
      # rubocop:enable Metrics/MethodLength

      # Replace `<<express:{schema}.{entity},{render}>>` with {{entity,render}}
      def express_reference_to_mention(description)
        # TODO: Use Expressir to check whether the "entity" is really an
        # EXPRESS ENTITY. If not, skip the mention.
        description.gsub(/<<express:([^,]+),([^>]+)>>/) do |_match|
          "{{#{Regexp.last_match[1].split('.').last},#{Regexp.last_match[2]}}}"
        end
      end

      def entity_name_to_text(entity_id)
        entity_id.downcase.gsub(/_/, " ")
      end

      # No longer used
      # def entity_ref(entity_id)
      #   if entity_id == entity_name_to_text(entity_id)
      #     "{{#{entity_id}}}"
      #   else
      #     "{{#{entity_id},#{entity_name_to_text(entity_id)}}}"
      #   end
      # end

      # rubocop:disable Layout/LineLength
      def generate_entity_definition(entity, _domain, schema_type)
        return "" if entity.nil?

        # See: metanorma/iso-10303-2#90
        entity_type = case schema_type
                      when "module_arm"
                        "{{application object}}"
                      when "module_mim"
                        "{{entity data type}}"
                      when "resource", "business_object_model"
                        "{{entity data type}}"
                      else
                        raise Error.new("[stepmod-utils] encountered unsupported schema_type")
                      end

        if entity.subtype_of.empty?
          "#{entity_type} " \
            "that represents the " \
            "#{entity_name_to_text(entity.id)} {{entity}}"
        else
          entity_subtypes = entity.subtype_of.map do |e|
            "{{#{e.id}}}"
          end

          "#{entity_type} that is a type of " \
            "#{entity_subtypes.join(' and ')} " \
            "that represents the " \
            "#{entity_name_to_text(entity.id)} {{entity}}"
        end
      end

      def format_remark_items(remark_items)
        notes = remark_items.detect { |i| i.id == "__note" }&.remarks
        examples = remark_items.detect { |i| i.id == "__example" }&.remarks

        formatted_notes = format_remarks(notes, "NOTE", "--")
        formatted_examples = format_remarks(examples, "example", "====")

        formatted_notes + formatted_examples
      end
      # rubocop:enable Layout/LineLength

      def format_remarks(remarks, remark_item_name, remark_item_symbol)
        return "" if remarks.nil?

        remarks.map do |remark|
          <<~REMARK

            [#{remark_item_name}]
            #{remark_item_symbol}
            #{remark}
            #{remark_item_symbol}
          REMARK
        end.join
      end

      def redundant_note?(note)
        return true if note.nil?

        note.match?(REDUNDENT_NOTE_REGEX) && !note.include?("\n")
      end
    end
  end
end
