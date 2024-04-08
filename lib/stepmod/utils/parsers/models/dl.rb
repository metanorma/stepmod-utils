require 'shale'

require_relative 'dd'
require_relative 'dt'

class Dl < Shale::Mapper
  attribute :dt, Dt, collection: true
  attribute :dd, Dd, collection: true

  xml do
    root 'dl'

    map_element 'dt', to: :dt
    map_element 'dd', to: :dd
  end
end
