require 'json'
require 'stepmod/utils/smrl_description_converter'
require 'stepmod/utils/smrl_resource_converter'

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
        descriptions_base = match ? "#{match.captures[0]}_descriptions.xml" : 'descriptions.xml'
        descriptions_file = File.join(File.dirname(express_file), descriptions_base)
        output_express = File.read(express_file)
        resource_docs_cache = JSON.parse(File.read(resource_docs_cache_file))

        if File.exists?(descriptions_file)
          descriptions = Nokogiri::XML(File.read(descriptions_file)).root
          descriptions.xpath('ext_description').each do |description|
            unless description.text.strip.empty? then
              Dir.chdir(File.dirname(descriptions_file)) do
                wrapper = "<ext_descriptions>#{description.to_s}</ext_descriptions>"
                output_express << "\n" + Stepmod::Utils::SmrlDescriptionConverter.convert(wrapper)
              end
            else
              # remark is empty, fallback to resource_docs_cache
              resource_docs_dir = resource_docs_cache[description['linkend']]
              if resource_docs_dir
                resource_docs_file = File.join(stepmod_dir, 'data/resource_docs', resource_docs_dir, 'resource.xml')
                resource_docs = Nokogiri::XML(File.read(resource_docs_file)).root
                schema = resource_docs.xpath("schema[@name='#{description['linkend']}']")

                Dir.chdir(File.dirname(descriptions_file)) do
                  wrapper = "<resource>#{schema.to_s}</resource>"
                  output_express << "\n" + Stepmod::Utils::SmrlResourceConverter.convert(wrapper)
                end
              end
            end
          end
        end

        output_express
      end
    end
  end
end
