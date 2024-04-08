require 'shale'

class Imgarea < Shale::Mapper
  attribute :shape, Shale::Type::String
  attribute :coords, Shale::Type::String
  attribute :href, Shale::Type::String

  xml do
    root 'img.area'

    map_attribute 'shape', to: :shape
    map_attribute 'coords', to: :coords
    map_attribute 'href', to: :href
  end
end
