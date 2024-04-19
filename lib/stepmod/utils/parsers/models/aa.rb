require "shale"

require_relative "aimelt"
require_relative "alt"
require_relative "alt_map"
require_relative "description"
require_relative "express_ref"
require_relative "refpath"
require_relative "refpath_extend"
require_relative "rules"
require_relative "source"

class Aa < Shale::Mapper
  attribute :attribute, Shale::Type::String
  attribute :assertion_to, Shale::Type::String
  attribute :inherited_from_module, Shale::Type::Value
  attribute :inherited_from_entity, Shale::Type::Value
  attribute :alt, Alt
  attribute :description, Description
  attribute :aimelt, Aimelt
  attribute :source, Source
  attribute :rules, Rules
  attribute :express_ref, ExpressRef, collection: true
  attribute :refpath, Refpath
  attribute :refpath_extend, RefpathExtend
  attribute :alt_map, AltMap, collection: true

  xml do
    root 'aa'

    map_attribute 'attribute', to: :attribute
    map_attribute 'assertion_to', to: :assertion_to
    map_attribute 'inherited_from_module', to: :inherited_from_module
    map_attribute 'inherited_from_entity', to: :inherited_from_entity
    map_element 'alt', to: :alt
    map_element 'description', to: :description
    map_element 'aimelt', to: :aimelt
    map_element 'source', to: :source
    map_element 'rules', to: :rules
    map_element 'express_ref', to: :express_ref
    map_element 'refpath', to: :refpath
    map_element 'refpath_extend', to: :refpath_extend
    map_element 'alt_map', to: :alt_map
  end
end
