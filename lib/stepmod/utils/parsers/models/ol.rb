require "shale"

require_relative "li"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Ol < Shale::Mapper
          attribute :type, Shale::Type::String
          attribute :start, Shale::Type::String
          attribute :li, Li, collection: true

          xml do
            root "ol"

            map_attribute "type", to: :type
            map_attribute "start", to: :start
            map_element "li", to: :li
          end
        end
      end
    end
  end
end
