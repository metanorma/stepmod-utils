require "shale"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Constraint < Shale::Mapper
          attribute :content, Shale::Type::String

          xml do
            root "constraint"

            map_content to: :content
          end
        end
      end
    end
  end
end
