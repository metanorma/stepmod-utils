require "shale"

require_relative "alt_scmap"
require_relative "description"
require_relative "rules"
require_relative "source"

class Sc < Shale::Mapper
  attribute :constraint, Shale::Type::Value
  attribute :entity, Shale::Type::Value
  attribute :original_module, Shale::Type::Value
  attribute :description, Description
  attribute :rules, Rules
  attribute :source, Source
  attribute :alt_scmap, AltScmap

  xml do
    root 'sc'

    map_attribute 'constraint', to: :constraint
    map_attribute 'entity', to: :entity
    map_attribute 'original_module', to: :original_module
    map_element 'description', to: :description
    map_element 'rules', to: :rules
    map_element 'source', to: :source
    map_element 'alt_scmap', to: :alt_scmap
  end
end
