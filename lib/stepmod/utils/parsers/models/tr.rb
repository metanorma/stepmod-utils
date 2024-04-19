require "shale"

require_relative "td"
require_relative "th"

class Tr < Shale::Mapper
  attribute :align, Shale::Type::String
  attribute :th, Th, collection: true
  attribute :td, Td, collection: true

  xml do
    root 'tr'

    map_attribute 'align', to: :align
    map_element 'th', to: :th
    map_element 'td', to: :td
  end
end
