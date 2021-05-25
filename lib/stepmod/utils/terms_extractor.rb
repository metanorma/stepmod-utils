require 'stepmod/utils/stepmod_definition_converter'
require 'stepmod/utils/bibdata'
require 'stepmod/utils/concept'

ReverseAdoc.config.unknown_tags = :bypass

module Stepmod
  module Utils
    class TermsExtractor
      # TODO: we may want a command line option to override this in the future
      ACCEPTED_STAGES = %w(IS DIS FDIS TS)

      attr_reader :stepmod_path,
        :stepmod_dir,
        :general_concepts,
        :resource_concepts,
        :parsed_bibliography,
        :encountered_terms,
        :cvs_mode,
        :part_concepts,
        :part_resources,
        :part_modules,
        :stdout

      def self.call(stepmod_dir, stdout = STDOUT)
        new(stepmod_dir, stdout).call
      end

      def initialize(stepmod_dir, stdout)
        @stdout = stdout
        @stepmod_dir = stepmod_dir
        @stepmod_path = Pathname.new(stepmod_dir).realpath
        @general_concepts = []
        @resource_concepts = []
        @parsed_bibliography = []
        @part_concepts = []
        @part_resources = []
        @part_modules = []
        @encountered_terms = {}
      end

      def log message
        stdout.puts "[stepmod-utils] #{message}"
      end

      def term_special_category(bibdata)
        case bibdata.part.to_i
        when 41,42,43,44,45,46,47,51
          true
        when [56..112]
          true
        else
          false
        end
      end

      def call
        # If we are using the stepmod CVS repository, provide the revision number per file
        @cvs_mode = if Dir.exists?(stepmod_path.join('CVS'))
          require 'ptools'
          # ptools provides File.which
          File.which("cvs")
        end

        log "INFO: STEPmod directory set to #{stepmod_dir}."

        if cvs_mode
          log "INFO: STEPmod directory is a CVS repository and will detect revisions."
          log "INFO: [CVS] Detecting file revisions can be slow, please be patient!"
        else
          log "INFO: STEPmod directory is not a CVS repository, skipping revision detection."
        end

        log "INFO: Detecting paths..."

        repo_index = Nokogiri::XML(File.read(stepmod_path.join('repository_index.xml'))).root

        files = []

        # add module paths
        repo_index.xpath('//module').each do |x|
          path = Pathname.new("#{stepmod_dir}/modules/#{x['name']}/module.xml")
          files << path if File.exists? path
        end

        # add resource_docs paths
        repo_index.xpath('//resource_doc').each do |x|
          path = Pathname.new("#{stepmod_dir}/resource_docs/#{x['name']}/resource.xml")
          files << path if File.exists? path
        end

        # add business_object_models paths
        repo_index.xpath('//business_object_model').each do |x|
          path = Pathname.new("#{stepmod_dir}/business_object_models/#{x['name']}/business_object_model.xml")
          files << path if File.exists? path
        end

        # add application_protocols paths
        repo_index.xpath('//application_protocol').each do |x|
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
          part_modules
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
          rescue
            log "WARNING: Unknown file #{fpath}, skipped"
            next
          end

          unless ACCEPTED_STAGES.include? bibdata.doctype
            log "INFO: skipped #{bibdata.docid} as it is not one of (#{ACCEPTED_STAGES.join(", ")})."
            next
          end

          if bibdata.part.to_s.empty?
            log "FATAL: missing `part` attribute: #{fpath}"
            log "INFO: skipped #{bibdata.docid} as it is missing `part` attribute."
            next
          end

          revision_string = "\n// CVS: revision not detected"
          if cvs_mode
            # Run `cvs status` to find out version

            log "INFO: Detecting CVS revision..."
            Dir.chdir(stepmod_path) do
              status = `cvs status #{fpath}`

              unless status.empty?
                working_rev = status.split(/\n/).grep(/Working revision:/).first.match(/revision:\s+(.+)$/)[1]
                repo_rev = status.split(/\n/).grep(/Repository revision:/).first.match(/revision:\t(.+)\t/)[1]
                log "INFO: CVS working rev (#{working_rev}), repo rev (#{repo_rev})"
                revision_string = "\n// CVS working rev: (#{working_rev}), repo rev (#{repo_rev})\n" +
                  "// CVS: revision #{working_rev == repo_rev ? 'up to date' : 'differs'}"
              end
            end
          end

          # read definitions
          current_part_concepts = []
          definition_index = 0
          current_document.xpath('//definition').each do |definition|
            definition_index += 1
            term_id = definition['id']
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
              file_path: fpath + revision_string
            )
            next unless concept

            unless term_special_category(bibdata)
              # log "INFO: this part is generic"
              general_concepts << concept
            else
              # log "INFO: this part is special"
              current_part_concepts << concept
            end

            parsed_bibliography << bibdata
          end

          current_part_resources = []
          current_part_modules_arm = {}
          current_part_modules_mim = {}

          log "INFO: FILE PATH IS #{file_path}"
          case file_path.to_s
          when /resource.xml$/
            log "INFO: Processing resource.xml for #{file_path}"
            # Assumption: every schema is only linked by a single resource_docs document.
            current_document.xpath('//schema').each do |schema_node|
              schema_name = schema_node['name']
              if parsed_schema_names[schema_name]
                log "ERROR: We have encountered this schema before: #{schema_name} from path #{parsed_schema_names[schema_name]}, now at #{file_path}"
                next
              else
                parsed_schema_names[schema_name] = file_path
              end

              Dir["#{stepmod_path}/resources/#{schema_name}/descriptions.xml"].each do |description_xml_path|
                log "INFO: Processing resources schema #{description_xml_path}"
                description_document = Nokogiri::XML(File.read(description_xml_path)).root
                description_document.xpath('//ext_description').each do |ext_description|

                  # log "INFO: Processing linkend[#{ext_description['linkend']}]"

                  concept = Stepmod::Utils::Concept.parse(
                    ext_description,
                    reference_anchor: bibdata.anchor,
                    reference_clause: nil,
                    file_path: Pathname.new(description_xml_path).relative_path_from(stepmod_path)
                  )
                  next unless concept

                  unless term_special_category(bibdata)
                    # log "INFO: this part is generic"
                    resource_concepts << concept
                  else
                    # log "INFO: this part is special"
                    current_part_resources << concept
                  end

                  parsed_bibliography << bibdata
                end
              end
            end

          when /module.xml$/
            log "INFO: Processing module.xml for #{file_path}"
            # Assumption: every schema is only linked by a single module document.
            # puts current_document.xpath('//module').length
            schema_name = current_document.xpath('//module').first['name']
            if parsed_schema_names[schema_name]
              log "ERROR: We have encountered this schema before: #{schema_name} from path #{parsed_schema_names[schema_name]}, now at #{file_path}"
              next
            else
              parsed_schema_names[schema_name] = file_path
            end

            description_xml_path = "#{stepmod_path}/modules/#{schema_name}/arm_descriptions.xml"
            log "INFO: Processing modules schema #{description_xml_path}"

            if File.exists?(description_xml_path)
              description_document = Nokogiri::XML(File.read(description_xml_path)).root
              description_document.xpath('//ext_description').each do |ext_description|

                linkend_schema = ext_description['linkend'].split('.').first
                concept = Stepmod::Utils::Concept.parse(
                  ext_description,
                  reference_anchor: bibdata.anchor,
                  reference_clause: nil,
                  file_path: Pathname.new(description_xml_path).relative_path_from(stepmod_path)
                )
                next unless concept

                current_part_modules_arm[linkend_schema] ||= []
                current_part_modules_arm[linkend_schema] << concept
                # puts part_modules_arm.inspect
                parsed_bibliography << bibdata
              end
            end

            description_xml_path = "#{stepmod_path}/modules/#{schema_name}/mim_descriptions.xml"
            log "INFO: Processing modules schema #{description_xml_path}"

            if File.exists?(description_xml_path)
              description_document = Nokogiri::XML(File.read(description_xml_path)).root
              description_document.xpath('//ext_description').each do |ext_description|

                linkend_schema = ext_description['linkend'].split('.').first

                concept = Stepmod::Utils::Concept.parse(
                  ext_description,
                  reference_anchor: bibdata.anchor,
                  reference_clause: nil,
                  file_path: Pathname.new(description_xml_path).relative_path_from(stepmod_path)
                )
                next unless concept

                current_part_modules_mim[linkend_schema] ||= []
                current_part_modules_mim[linkend_schema] << concept

                parsed_bibliography << bibdata
              end
            end

          end

          log "INFO: Completed processing XML file #{fpath}"
          if current_part_concepts.empty?
            log "INFO: Skipping #{fpath} (#{bibdata.docid}) because it contains no concepts."
          elsif current_part_concepts.length < 3
            log "INFO: Skipping #{fpath} (#{bibdata.docid}) because it only has #{current_part_concepts.length} terms."

            current_part_concepts.each do |x|
              general_concepts << x
            end
          else
            part_concepts << [bibdata, current_part_concepts] unless current_part_concepts.empty?
          end
          part_resources << [bibdata, current_part_resources] unless current_part_resources.empty?
          part_modules << [bibdata, current_part_modules_arm, current_part_modules_mim] if current_part_modules_arm.size + current_part_modules_mim.size > 0
        end
      end
    end
  end
end
