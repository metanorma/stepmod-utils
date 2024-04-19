require "shale"

require_relative "li"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Ul < Shale::Mapper
          attribute :li, Li, collection: true

          xml do
            root "ul"

            map_element "li", to: :li
          end
        end
      end
    end
  end
end
