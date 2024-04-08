require 'shale'

require_relative 'img'
require_relative 'title'

class Figure < Shale::Mapper
  attribute :id, Shale::Type::Value
  attribute :number, Shale::Type::String
  attribute :letter, Shale::Type::String
  attribute :title, Title
  attribute :img, Img

  xml do
    root 'figure'

    map_attribute 'id', to: :id
    map_attribute 'number', to: :number
    map_attribute 'letter', to: :letter
    map_element 'title', to: :title
    map_element 'img', to: :img
  end
end
