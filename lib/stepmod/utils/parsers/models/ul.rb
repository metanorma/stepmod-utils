require 'shale'

require_relative 'li'

class Ul < Shale::Mapper
  attribute :li, Li, collection: true

  xml do
    root 'ul'

    map_element 'li', to: :li
  end
end
