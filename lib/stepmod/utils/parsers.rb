require 'shale/adapter/nokogiri'
require_relative "parsers/mapping_table_parser"

Shale.xml_adapter = Shale::Adapter::Nokogiri
