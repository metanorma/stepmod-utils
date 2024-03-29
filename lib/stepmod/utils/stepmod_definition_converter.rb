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
require "stepmod/utils/converters/stem"
require "stepmod/utils/converters/stepmod_ext_description"
require "stepmod/utils/converters/term"
require "stepmod/utils/converters/synonym"
require "stepmod/utils/converters/uof"
require "stepmod/utils/converters/figure"
require "stepmod/utils/converters/table"
require "stepmod/utils/cleaner"

require "reverse_adoc/converters/a"
require "reverse_adoc/converters/blockquote"
require "reverse_adoc/converters/bypass"
require "reverse_adoc/converters/br"
require "reverse_adoc/converters/code"
require "reverse_adoc/converters/drop"
require "reverse_adoc/converters/head"
require "reverse_adoc/converters/hr"
require "reverse_adoc/converters/ignore"
require "reverse_adoc/converters/li"
require "reverse_adoc/converters/p"
require "reverse_adoc/converters/pass_through"
require "reverse_adoc/converters/q"
require "reverse_adoc/converters/strong"
require "reverse_adoc/converters/sup"
require "reverse_adoc/converters/sub"
require "reverse_adoc/converters/text"

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

        ReverseAdoc.config.with(options) do
          result = ReverseAdoc::Converters.lookup(root.name).convert(root,
                                                                     options)
          return "" unless result

          Stepmod::Utils::Cleaner.new.tidy(result.dup)
        end
      end
    end
  end
end
