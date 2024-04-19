require "shale"

require_relative "tr"

class Table < Shale::Mapper
  attribute :caption, Shale::Type::String
  attribute :id, Shale::Type::String
  attribute :number, Shale::Type::String
  attribute :width, Shale::Type::String
  attribute :tr, Tr, collection: true

  xml do
    root 'table'

    map_attribute 'caption', to: :caption
    map_attribute 'id', to: :id
    map_attribute 'number', to: :number
    map_attribute 'width', to: :width
    map_element 'tr', to: :tr
  end
end
