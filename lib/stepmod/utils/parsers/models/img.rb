require "shale"

require_relative "imgarea"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Img < Shale::Mapper
          attribute :src, Shale::Type::String
          attribute :alt, Shale::Type::String
          attribute :img_area, Imgarea, collection: true

          xml do
            root "img"

            map_attribute "src", to: :src
            map_attribute "alt", to: :alt
            map_element "img.area", to: :img_area
          end
        end
      end
    end
  end
end
