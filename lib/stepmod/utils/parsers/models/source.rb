require "shale"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Source < Shale::Mapper
          attribute :content, Shale::Type::String
          attribute :space, Shale::Type::Value

          xml do
            root "source"

            map_content to: :content
            map_attribute "space", to: :space
          end
        end
      end
    end
  end
end
