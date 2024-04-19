require "shale"

require_relative "../types/string_without_indent"

require_relative "ae"
require_relative "sc"

module Stepmod
  module Utils
    module Parsers
      module Models
        class MappingTable < Shale::Mapper
          attribute :ae, Ae, collection: true
          attribute :sc, Sc, collection: true

          xml do
            root "mapping_table"

            map_element "ae", to: :ae
            map_element "sc", to: :sc
          end
        end
      end
    end
  end
end
