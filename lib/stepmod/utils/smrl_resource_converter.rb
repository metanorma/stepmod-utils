# frozen_string_literal: true

require "reverse_adoc"
require "reverse_adoc/converters/bypass"
require "reverse_adoc/converters/pass_through"
require "stepmod/utils/converters/a"
require "stepmod/utils/converters/blockquote"
require "stepmod/utils/converters/br"
require "stepmod/utils/converters/bypass"
require "stepmod/utils/converters/code"
require "stepmod/utils/converters/comment"
require "stepmod/utils/converters/dd"
require "stepmod/utils/converters/dl"
require "stepmod/utils/converters/dt"
require "stepmod/utils/converters/drop"
require "stepmod/utils/converters/example"
require "stepmod/utils/converters/express_g"
require "stepmod/utils/converters/figure"
require "stepmod/utils/converters/fund_cons"
require "stepmod/utils/converters/eqn"
require "stepmod/utils/converters/head"
require "stepmod/utils/converters/hr"
require "stepmod/utils/converters/ignore"
require "stepmod/utils/converters/introduction"
require "stepmod/utils/converters/note"
require "stepmod/utils/converters/ol"
require "stepmod/utils/converters/p"
require "stepmod/utils/converters/pass_through"
require "stepmod/utils/converters/q"
require "stepmod/utils/converters/resource"
require "stepmod/utils/converters/schema_diag"
require "stepmod/utils/converters/schema"
require "stepmod/utils/converters/strong"
require "stepmod/utils/converters/sub"
require "stepmod/utils/converters/sup"
require "stepmod/utils/converters/table"
require "stepmod/utils/converters/text"
require "stepmod/utils/cleaner"

require "reverse_adoc/converters/img"
require "reverse_adoc/converters/li"
require "reverse_adoc/converters/tr"
require "reverse_adoc/converters/td"
require "reverse_adoc/converters/th"

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

        ReverseAdoc.config.with(options) do
          result = ReverseAdoc::Converters.lookup(root.name).convert(root, options)

          Stepmod::Utils::Cleaner.new.tidy(result)
        end
      end
    end
  end
end
