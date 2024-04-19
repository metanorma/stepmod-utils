require "shale"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Rules < Shale::Mapper
          attribute :content, Shale::Type::String

          xml do
            root "rules"

            map_content to: :content
          end
        end
      end
    end
  end
end
