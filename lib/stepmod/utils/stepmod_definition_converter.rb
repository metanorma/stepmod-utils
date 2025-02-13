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

require "coradoc/input/html/converters/a"
require "coradoc/input/html/converters/blockquote"
require "coradoc/input/html/converters/bypass"
require "coradoc/input/html/converters/br"
require "coradoc/input/html/converters/code"
require "coradoc/input/html/converters/drop"
require "coradoc/input/html/converters/head"
require "coradoc/input/html/converters/hr"
require "coradoc/input/html/converters/ignore"
require "coradoc/input/html/converters/li"
require "coradoc/input/html/converters/p"
require "coradoc/input/html/converters/pass_through"
require "coradoc/input/html/converters/q"
require "coradoc/input/html/converters/strong"
require "coradoc/input/html/converters/sup"
require "coradoc/input/html/converters/sub"
require "coradoc/input/html/converters/text"

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

        Coradoc::Input::HTML.config.with(options) do
          result = Coradoc::Input::HTML::Converters.lookup(root.name).convert(root,
                                                                              options)
          return "" unless result

          Stepmod::Utils::Cleaner.new.tidy(result.dup)
        end
      end
    end
  end
end
