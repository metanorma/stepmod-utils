# frozen_string_literal: true

require "stepmod/utils/converters/base"
require "coradoc/input/html/converters/bypass"
require "coradoc/input/html/converters/pass_through"
require "stepmod/utils/converters/a"
require "stepmod/utils/converters/comment"
require "stepmod/utils/converters/dd"
require "stepmod/utils/converters/dl"
require "stepmod/utils/converters/dt"
require "stepmod/utils/converters/example"
require "stepmod/utils/converters/express_g"
require "stepmod/utils/converters/figure"
require "stepmod/utils/converters/fund_cons"
require "stepmod/utils/converters/eqn"
require "stepmod/utils/converters/introduction"
require "stepmod/utils/converters/note"
require "stepmod/utils/converters/ol"
require "stepmod/utils/converters/pass_through"
require "stepmod/utils/converters/module_ref"
require "stepmod/utils/converters/resource"
require "stepmod/utils/converters/schema_diag"
require "stepmod/utils/converters/schema"
require "stepmod/utils/converters/strong"
require "stepmod/utils/converters/sub"
require "stepmod/utils/converters/sup"
require "stepmod/utils/converters/table"
require "stepmod/utils/converters/text"
require "stepmod/utils/converters/tr"
require "stepmod/utils/converters/li"
require "stepmod/utils/cleaner"

require "coradoc/input/html/converters/img"
require "coradoc/input/html/converters/li"
require "coradoc/input/html/converters/tr"
require "coradoc/input/html/converters/td"
require "coradoc/input/html/converters/th"

module Stepmod
  module Utils
    class SmrlResourceConverter
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

        Coradoc::Input::Html.config.with(options) do
          result = Coradoc::Input::Html::Converters.lookup(root.name).convert(root,
                                                                              options)

          Stepmod::Utils::Cleaner.new.tidy(result)
        end
      end
    end
  end
end
