require "shale"

module Stepmod
  module Utils
    module Parsers
      module Models
        class RefpathExtend < Shale::Mapper
          attribute :content, Shale::Type::String
          attribute :extended_select, Shale::Type::Value
          attribute :space, Shale::Type::Value

          xml do
            root "refpath_extend"

            map_content to: :content
            map_attribute "extended_select", to: :extended_select
            map_attribute "space", to: :space
          end
        end
      end
    end
  end
end
