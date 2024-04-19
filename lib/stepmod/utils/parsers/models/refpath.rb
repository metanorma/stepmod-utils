require "shale"
require_relative "../types/string_without_indent"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Refpath < Shale::Mapper
          attribute :content,
                    Stepmod::Utils::Parsers::Types::StringWithoutIndent
          attribute :space, Shale::Type::Value

          xml do
            root "refpath"

            map_content to: :content
            map_attribute "space", to: :space
          end
        end
      end
    end
  end
end
