# frozen_string_literal: true

require "stepmod/utils/converters/base"
require "stepmod/utils/converters/a"
require "stepmod/utils/converters/blockquote"
require "stepmod/utils/converters/br"
require "stepmod/utils/converters/bypass"
require "stepmod/utils/converters/code"
require "stepmod/utils/converters/description"
require "stepmod/utils/converters/drop"
require "stepmod/utils/converters/em_express_description"
require "stepmod/utils/converters/example"
require "stepmod/utils/converters/express_ref_express_description"
require "stepmod/utils/converters/ext_description"
require "stepmod/utils/converters/ext_descriptions"
require "stepmod/utils/converters/head"
require "stepmod/utils/converters/hr"
require "stepmod/utils/converters/ignore"
require "stepmod/utils/converters/module_ref_express_description"
require "stepmod/utils/converters/note"
require "stepmod/utils/converters/p"
require "stepmod/utils/converters/pass_through"
require "stepmod/utils/converters/q"
require "stepmod/utils/converters/strong"
require "stepmod/utils/converters/sub"
require "stepmod/utils/converters/sup"
require "stepmod/utils/converters/text"
require "stepmod/utils/cleaner"

module Stepmod
  module Utils
    class SmrlDescriptionConverter
      def self.convert(input, options = {})
        root = case input
               when String
                 Nokogiri::XML(input).root
               when Nokogiri::XML::Document
                 input.root
               when Nokogiri::XML::Node
                 input
               end

        root || (return "")

        ReverseAdoc.config.with(options) do
          result = ReverseAdoc::Converters.lookup(root.name).convert(root, options)
          Stepmod::Utils::Cleaner.new.tidy(result)
        end
      end
    end
  end
end
