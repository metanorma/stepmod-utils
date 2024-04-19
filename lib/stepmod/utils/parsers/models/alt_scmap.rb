require "shale"

require_relative "constraint"
require_relative "description"
require_relative "rules"
require_relative "source"

class AltScmap < Shale::Mapper
  attribute :id, Shale::Type::String
  attribute :alt_scmap_inc, Shale::Type::String
  attribute :description, Description
  attribute :constraint, Constraint
  attribute :rules, Rules
  attribute :source, Source

  xml do
    root 'alt_scmap'

    map_attribute 'id', to: :id
    map_attribute 'alt_scmap.inc', to: :alt_scmap_inc
    map_element 'description', to: :description
    map_element 'constraint', to: :constraint
    map_element 'rules', to: :rules
    map_element 'source', to: :source
  end
end
