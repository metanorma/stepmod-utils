require "shale"

require_relative "dd"
require_relative "dt"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Dl < Shale::Mapper
          attribute :dt, Dt, collection: true
          attribute :dd, Dd, collection: true

          xml do
            root "dl"

            map_element "dt", to: :dt
            map_element "dd", to: :dd
          end
        end
      end
    end
  end
end
