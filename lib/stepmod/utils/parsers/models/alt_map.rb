require "shale"

require_relative "aimelt"
require_relative "alt"
require_relative "description"
require_relative "express_ref"
require_relative "refpath"
require_relative "refpath_extend"
require_relative "rules"
require_relative "source"

class AltMap < Shale::Mapper
  attribute :id, Shale::Type::String
  attribute :alt_map_inc, Shale::Type::String
  attribute :alt, Alt
  attribute :description, Description
  attribute :aimelt, Aimelt
  attribute :source, Source
  attribute :rules, Rules
  attribute :express_ref, ExpressRef, collection: true
  attribute :refpath, Refpath
  attribute :refpath_extend, RefpathExtend

  xml do
    root 'alt_map'

    map_attribute 'id', to: :id
    map_attribute 'alt_map.inc', to: :alt_map_inc
    map_element 'alt', to: :alt
    map_element 'description', to: :description
    map_element 'aimelt', to: :aimelt
    map_element 'source', to: :source
    map_element 'rules', to: :rules
    map_element 'express_ref', to: :express_ref
    map_element 'refpath', to: :refpath
    map_element 'refpath_extend', to: :refpath_extend
  end
end
