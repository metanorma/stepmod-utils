# frozen_string_literal: true

require "stepmod/utils/converters/base"
require "stepmod/utils/converters/arm"
require "stepmod/utils/converters/clause_ref"
require "stepmod/utils/converters/express_ref"
require "stepmod/utils/converters/module_ref"
require "stepmod/utils/converters/def"
require "stepmod/utils/converters/definition"
require "stepmod/utils/converters/em"
require "stepmod/utils/converters/example"
require "stepmod/utils/converters/note"
require "stepmod/utils/converters/ol"
require "stepmod/utils/converters/stepmod_ext_description"
require "stepmod/utils/converters/term"
require "stepmod/utils/converters/synonym"
require "stepmod/utils/converters/figure"
require "stepmod/utils/converters/table"
require "stepmod/utils/cleaner"

require "ceradoc/html/converters/a"
require "ceradoc/html/converters/blockquote"
require "ceradoc/html/converters/bypass"
require "ceradoc/html/converters/br"
require "ceradoc/html/converters/code"
require "ceradoc/html/converters/drop"
require "ceradoc/html/converters/head"
require "ceradoc/html/converters/hr"
require "ceradoc/html/converters/drop" # old coradoc Ignore (colgroup/col) is the ceradoc Skip registry
require "ceradoc/html/converters/li"
require "ceradoc/html/converters/pass_through"
require "ceradoc/html/converters/q"
require "ceradoc/html/converters/strong"
require "ceradoc/html/converters/sup"
require "ceradoc/html/converters/sub"
require "ceradoc/html/converters/text"

module Stepmod
  module Utils
    class StepmodDefinitionConverter
      def self.convert(input, options = {})
        root = case input
               when String
                 Nokogiri::XML(input).root
               when Nokogiri::XML::Document
                 input.root
               when Nokogiri::XML::Node
                 input
               end

        return "" unless root

        Ceradoc::Html.input_config.with(options) do
          result = Ceradoc::Html::Converters.lookup(root.name).convert(root,
                                                                              options)
          return "" unless result

          Stepmod::Utils::Cleaner.new.tidy(result.dup)
        end
      end
    end
  end
end
