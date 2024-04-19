require "shale"

require_relative "aa"
require_relative "aimelt"
require_relative "alt"
require_relative "alt_map"
require_relative "description"
require_relative "express_ref"
require_relative "refpath"
require_relative "refpath_extend"
require_relative "rules"
require_relative "source"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Ae < Shale::Mapper
          attribute :entity, Shale::Type::Value
          attribute :extensible, Shale::Type::String
          attribute :original_module, Shale::Type::Value
          attribute :alt, Alt
          attribute :description, Description
          attribute :aimelt, Aimelt
          attribute :source, Source
          attribute :rules, Rules
          attribute :express_ref, ExpressRef, collection: true
          attribute :refpath, Refpath
          attribute :refpath_extend, RefpathExtend
          attribute :alt_map, AltMap, collection: true
          attribute :aa, Aa, collection: true

          xml do
            root "ae"

            map_attribute "entity", to: :entity
            map_attribute "extensible", to: :extensible
            map_attribute "original_module", to: :original_module
            map_element "alt", to: :alt
            map_element "description", to: :description
            map_element "aimelt", to: :aimelt
            map_element "source", to: :source
            map_element "rules", to: :rules
            map_element "express_ref", to: :express_ref
            map_element "refpath", to: :refpath
            map_element "refpath_extend", to: :refpath_extend
            map_element "alt_map", to: :alt_map
            map_element "aa", to: :aa
          end
        end
      end
    end
  end
end
