# frozen_string_literal: true

require 'reverse_adoc'
require 'stepmod/utils/converters/arm'
require 'stepmod/utils/converters/clause_ref'
require 'stepmod/utils/converters/express_ref'
require 'stepmod/utils/converters/module_ref'
require 'stepmod/utils/converters/def'
require 'stepmod/utils/converters/definition'
require 'stepmod/utils/converters/em'
require 'stepmod/utils/converters/example'
require 'stepmod/utils/converters/note'
require 'stepmod/utils/converters/ol'
require 'stepmod/utils/converters/stem'
require 'stepmod/utils/converters/stepmod_ext_description'
require 'stepmod/utils/converters/term'
require 'stepmod/utils/converters/synonym'
require 'stepmod/utils/converters/uof'

require 'reverse_adoc/converters/a'
require 'reverse_adoc/converters/blockquote'
require 'reverse_adoc/converters/bypass'
require 'reverse_adoc/converters/br'
require 'reverse_adoc/converters/code'
require 'reverse_adoc/converters/drop'
require 'reverse_adoc/converters/head'
require 'reverse_adoc/converters/hr'
require 'reverse_adoc/converters/ignore'
require 'reverse_adoc/converters/li'
require 'reverse_adoc/converters/p'
require 'reverse_adoc/converters/pass_through'
require 'reverse_adoc/converters/q'
require 'reverse_adoc/converters/strong'
require 'reverse_adoc/converters/sup'
require 'reverse_adoc/converters/sub'
require 'reverse_adoc/converters/text'


module Stepmod
  module Utils
    class StepmodDefinitionConverter
      def self.convert(input, options = {})
        root = if input.is_a?(String)
                  then Nokogiri::XML(input).root
                elsif input.is_a?(Nokogiri::XML::Document)
                  then input.root
                elsif input.is_a?(Nokogiri::XML::Node)
                  then input
                end

        root || (return '')

        ReverseAdoc.config.with(options) do
          result = ReverseAdoc::Converters.lookup(root.name).convert(root)
          return '' unless result
          ReverseAdoc.cleaner.tidy(result.dup)
        end
      end
    end
  end
end
