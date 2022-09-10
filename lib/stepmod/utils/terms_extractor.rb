require "stepmod/utils/stepmod_definition_converter"
require "stepmod/utils/bibdata"
require "stepmod/utils/concept"
require "glossarist"
require "securerandom"
require "expressir"
require "expressir/express/parser"
require "indefinite_article"

ReverseAdoc.config.unknown_tags = :bypass

module Stepmod
  module Utils
    class TermsExtractor
      # TODO: we may want a command line option to override this in the future
      ACCEPTED_STAGES = %w(IS DIS FDIS TS).freeze
      WITHDRAWN_STATUS = "withdrawn".freeze

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
                  :stdout

      def self.call(stepmod_dir, index_path, stdout = $stdout)
        new(stepmod_dir, index_path, stdout).call
      end

      def initialize(stepmod_dir, index_path, stdout)
        @stdout = stdout
        @stepmod_dir = stepmod_dir
        @stepmod_path = Pathname.new(stepmod_dir).realpath
        @index_path = Pathname.new(index_path).to_s
        @general_concepts = Glossarist::Collection.new
        @resource_concepts = Glossarist::Collection.new
        @parsed_bibliography = []
        @part_concepts = []
        @part_resources = []
        @part_modules = []
        @encountered_terms = {}
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

      def call
        log "INFO: STEPmod directory set to #{stepmod_dir}."
        log "INFO: Detecting paths..."

        repo_index = Nokogiri::XML(File.read(@index_path)).root

        files = []

        # add module paths
        repo_index.xpath("//module").each do |x|
          next if x['status'] == WITHDRAWN_STATUS

          path = Pathname.new("#{stepmod_dir}/modules/#{x['name']}/module.xml")
          files << path if File.exists? path
        end

        # add resource_docs paths
        repo_index.xpath("//resource_doc").each do |x|
          next if x['status'] == WITHDRAWN_STATUS

          path = Pathname.new("#{stepmod_dir}/resource_docs/#{x['name']}/resource.xml")
          files << path if File.exists? path
        end

        # add business_object_models paths
        repo_index.xpath("//business_object_model").each do |x|
          next if x['status'] == WITHDRAWN_STATUS

          path = Pathname.new("#{stepmod_dir}/business_object_models/#{x['name']}/business_object_model.xml")
          files << path if File.exists? path
        end

        # add application_protocols paths
        repo_index.xpath("//application_protocol").each do |x|
          next if x['status'] == WITHDRAWN_STATUS

          path = Pathname.new("#{stepmod_dir}/application_protocols/#{x['name']}/application_protocol.xml")
          files << path if File.exists? path
        end

        files.sort!.uniq!
        process_term_files(files)

        [
          general_concepts,
          resource_concepts,
          parsed_bibliography,
          part_concepts,
          part_resources,
          part_modules,
        ]
      end

      private

      def process_term_files(files)
        parsed_schema_names = {}
        files.each do |file_path|
          file_path = file_path.realpath
          fpath = file_path.relative_path_from(stepmod_path)

          log "INFO: Processing XML file #{fpath}"
          current_document = Nokogiri::XML(File.read(file_path)).root

          bibdata = nil
          begin
            bibdata = Stepmod::Utils::Bibdata.new(document: current_document)
          rescue StandardError
            log "WARNING: Unknown file #{fpath}, skipped"
            next
          end

          unless ACCEPTED_STAGES.include? bibdata.doctype
            log "INFO: skipped #{bibdata.docid} as it is not " \
              "one of (#{ACCEPTED_STAGES.join(', ')})."
            next
          end

          if bibdata.part.to_s.empty?
            log "FATAL: missing `part` attribute: #{fpath}"
            log "INFO: skipped #{bibdata.docid} as it is missing `part` attribute."
            next
          end

          revision_string = ""

          # Run `cvs status` to find out version
          log "INFO: Detecting Git SHA..."
          Dir.chdir(stepmod_path) do
            git_sha = `git rev-parse HEAD`

            unless git_sha.empty?
              revision_string = "\n// Git: SHA #{git_sha}"
            end
          end

          # read definitions
          current_part_concepts = Glossarist::Collection.new
          definition_index = 0
          current_document.xpath("//definition").each do |definition|
            definition_index += 1
            term_id = definition["id"]
            unless term_id.nil?
              if encountered_terms[term_id]
                log "FATAL: Duplicated term with id: #{term_id}, #{fpath}"
              end
              encountered_terms[term_id] = true
            end

            # Assume that definition is located in clause 3 of the ISO document
            # in order. We really don't have a good reference here.
            ref_clause = "3.#{definition_index}"

            concept = Stepmod::Utils::Concept.parse(
              definition,
              reference_anchor: bibdata.anchor,
              reference_clause: ref_clause,
              file_path: fpath + revision_string,
            )
            next unless concept

            if term_special_category(bibdata)
              # log "INFO: this part is special"
              find_or_initialize_concept(current_part_concepts, concept)
            else
              # log "INFO: this part is generic"
              find_or_initialize_concept(general_concepts, concept)
            end

            parsed_bibliography << bibdata
          end

          current_part_resources = Glossarist::Collection.new
          current_part_modules_arm = {}
          current_part_modules_mim = {}

          log "INFO: FILE PATH IS #{file_path}"
          case file_path.to_s
          when /resource.xml$/
            log "INFO: Processing resource.xml for #{file_path}"

            current_document.xpath("//schema").each do |schema_node|
              schema_name = schema_node["name"]
              if parsed_schema_names[schema_name]
                log "ERROR: We have encountered this schema before: \
                  #{schema_name} from path \
                  #{parsed_schema_names[schema_name]}, now at #{file_path}"
                next
              else
                parsed_schema_names[schema_name] = file_path
              end

              exp_annotated_path =
                "#{stepmod_path}/resources/#{schema_name}/#{schema_name}_annotated.exp"

              log "INFO: Processing resources schema #{exp_annotated_path}"

              if File.exists?(exp_annotated_path)
                repo = Expressir::Express::Parser.from_file(exp_annotated_path)
                schema = repo.schemas.first

                schema.entities.each do |entity|
                  old_definition = entity.remarks.first

                  domain = "resource: #{schema.id}"
                  entity_definition = generate_entity_definition(entity, domain, old_definition)

                  reference_anchor = bibdata.anchor
                  reference_clause = nil

                  concept = Stepmod::Utils::Concept.new(
                    designations: [entity.id],
                    definition: old_definition,
                    converted_definition: entity_definition,
                    id: "#{reference_anchor}.#{reference_clause}",
                    reference_anchor: reference_anchor,
                    reference_clause: reference_clause,
                    file_path: Pathname.new(exp_annotated_path)
                                .relative_path_from(stepmod_path),
                    language_code: "en",
                  )

                  next unless concept

                  if term_special_category(bibdata)
                    # log "INFO: this part is special"
                    find_or_initialize_concept(current_part_resources, concept)
                  else
                    # log "INFO: this part is generic"
                    find_or_initialize_concept(resource_concepts, concept)
                  end

                  parsed_bibliography << bibdata
                end
              end
            end

          when /module.xml$/
            log "INFO: Processing module.xml for #{file_path}"
            # Assumption: every schema is only linked by a single module document.
            # puts current_document.xpath('//module').length
            schema_name = current_document.xpath("//module").first["name"]
            if parsed_schema_names[schema_name]
              log "ERROR: We have encountered this schema before: \
                #{schema_name} from path #{parsed_schema_names[schema_name]}, \
                  now at #{file_path}"
              next
            else
              parsed_schema_names[schema_name] = file_path
            end

            exp_annotated_path =
              "#{stepmod_path}/modules/#{schema_name}/arm_annotated.exp"

            log "INFO: Processing modules schema #{exp_annotated_path}"

            if File.exists?(exp_annotated_path)
              repo = Expressir::Express::Parser.from_file(exp_annotated_path)

              repo.schemas.each do |schema|
                schema.entities.each do |entity|
                  old_definition = entity.remarks.first

                  # See: metanorma/iso-10303-2#90
                  domain = "application object: #{schema.id}"
                  entity_definition = generate_entity_definition(entity, domain, old_definition)

                  reference_anchor = bibdata.anchor
                  reference_clause = nil

                  concept = Stepmod::Utils::Concept.new(
                    designations: [entity.id],
                    definition: old_definition,
                    converted_definition: entity_definition,
                    id: "#{reference_anchor}.#{reference_clause}",
                    reference_anchor: reference_anchor,
                    reference_clause: reference_clause,
                    file_path: Pathname.new(exp_annotated_path)
                                .relative_path_from(stepmod_path),
                    language_code: "en",
                  )

                  next unless concept

                  current_part_modules_arm[schema.id] ||=
                    Glossarist::Collection.new
                  find_or_initialize_concept(
                    current_part_modules_arm[schema.id], concept
                  )

                  # puts part_modules_arm.inspect
                  parsed_bibliography << bibdata
                end
              end
            end

            mim_exp_annotated_path = "#{stepmod_path}/modules/#{schema_name}/mim_annotated.exp"

            log "INFO: Processing modules schema #{mim_exp_annotated_path}"

            if File.exists?(mim_exp_annotated_path)
              repo = Expressir::Express::Parser.from_file(mim_exp_annotated_path)

              repo.schemas.each do |schema|
                schema.entities.each do |entity|
                  old_definition = entity.remarks.first

                  domain = "application module: #{schema.id}"
                  definition = generate_entity_definition(entity, domain, old_definition)

                  reference_anchor = bibdata.anchor
                  reference_clause = nil

                  concept = Stepmod::Utils::Concept.new(
                    designations: [entity.id],
                    definition: old_definition,
                    converted_definition: definition,
                    id: "#{reference_anchor}.#{reference_clause}",
                    reference_anchor: reference_anchor,
                    reference_clause: reference_clause,
                    file_path: Pathname.new(exp_annotated_path)
                                .relative_path_from(stepmod_path),
                    language_code: "en",
                  )

                  next unless concept

                  current_part_modules_mim[schema.id] ||=
                    Glossarist::Collection.new
                  find_or_initialize_concept(
                    current_part_modules_mim[schema.id], concept
                  )

                  parsed_bibliography << bibdata
                end
              end
            end

          end

          log "INFO: Completed processing XML file #{fpath}"
          if current_part_concepts.to_a.empty?
            log "INFO: Skipping #{fpath} (#{bibdata.docid}) " \
              "because it contains no concepts."
          elsif current_part_concepts.to_a.length < 3
            log "INFO: Skipping #{fpath} (#{bibdata.docid}) " \
              "because it only has #{current_part_concepts.to_a.length} terms."

            current_part_concepts.to_a.each do |x|
              general_concepts.store(x)
            end
          else
            unless current_part_concepts.to_a.empty?
              part_concepts << [bibdata,
                                current_part_concepts]
            end
          end

          unless current_part_resources.to_a.empty?
            part_resources << [bibdata,
                               current_part_resources]
          end

          if (current_part_modules_arm.to_a.size +
              current_part_modules_mim.to_a.size).positive?
            part_modules << [bibdata, current_part_modules_arm,
                             current_part_modules_mim]
          end

        end
      end

      def find_or_initialize_concept(collection, localized_concept)
        concept = collection
          .store(Glossarist::Concept.new(id: SecureRandom.uuid))
        concept.add_l10n(localized_concept)
      end

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
        if full_paragraph =~ /\.\s*\Z/
          # puts "CONDITION 2"
          return full_paragraph
        end

        # If next_paragraph is a list
        if next_paragraph.match(/\A\*/)
          # puts "CONDITION 3"
          return full_paragraph + "\n\n" + next_paragraph
        end

        # If next_paragraph is a continuation of a list
        if next_paragraph.match(/\Awhich/) || next_paragraph.match(/\Athat/)
          # puts "CONDITION 4"
          return full_paragraph + "\n\n" + next_paragraph
        end

        # puts "CONDITION 5"
        full_paragraph
      end

      def trim_definition(definition)
        # Unless the first paragraph ends with "between" and is followed by a
        # list, don't split
        paragraphs = definition.split("\n\n")

        # puts paragraphs.inspect

        first_paragraph = paragraphs.first

        if paragraphs.length > 1
          combined = paragraphs[1..-1].inject(first_paragraph) do |acc, p|
            combine_paragraphs(acc, p)
          end
        else
          combined = combine_paragraphs(first_paragraph, "")
        end

        # puts "combined--------- #{combined}"

        # Remove comments until end of line
        combined = combined + "\n"
        combined.gsub!(/\n\/\/.*?\n/, "\n")
        combined.strip!

        combined
        # # TODO: If the definition contains a list immediately after the first paragraph, don't split
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

      def entity_name_to_text(entity_id)
        entity_id.downcase.gsub(/_/, " ")
      end

      # rubocop:disable Layout/LineLength
      def generate_entity_definition(entity, domain, old_definition)
        return "" if entity.nil?

        # See: metanorma/iso-10303-2#90
        # TODO: This is not DRY in case we have to further customize
        entity_text = if domain =~ /\Aapplication object:/

          if entity.subtype_of.size.zero?
            "application object that represents the " +
            "{{#{entity.id},#{entity_name_to_text(entity.id)}}} entity"
          else
            entity_subtypes = entity.subtype_of.map do |e|
              "{{#{e.id},#{entity_name_to_text(e.id)}}}"
            end
            "application object that is a type of " +
            "#{entity_subtypes.join(' and ')} that represents the " +
            "{{#{entity.id},#{entity_name_to_text(entity.id)}}} entity"
          end

        else

          # Not "application object"
          if entity.subtype_of.size.zero?
            "entity data type that represents " +
            entity.id.indefinite_article + " {{#{entity.id}}} entity"
          else
            entity_subtypes = entity.subtype_of.map do |e|
              "{{#{e.id}}}"
            end
            "entity data type that is a type of "+
            "#{entity_subtypes.join(' and ')} that represents " +
            entity.id.indefinite_article + " {{#{entity.id}}} entity"
          end
        end

        definition = <<~DEFINITION
          === #{entity.id}
          domain:[#{domain}]

          #{entity_text}

        DEFINITION

        unless old_definition.nil? || old_definition.blank?
          old_definition = trim_definition(old_definition)

          definition << <<~OLD_DEFINITION
            [NOTE]
            --
            #{old_definition.strip}
            --
          OLD_DEFINITION
        end

        # We no longer add Notes and Examples to the extracted terms
        # definition + format_remark_items(entity.remark_items)

        definition
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
    end
  end
end
