require_relative "models/mapping_table"

module Stepmod
  module Utils
    module Parsers
      class MappingTableParser
        def self.parse(node)
          new(node).parse
        end

        def initialize(node)
          @node = node
          @xml = node.to_xml
        end

        def parse
          MappingTable.from_xml(@xml)
        end
      end
    end
  end
end
