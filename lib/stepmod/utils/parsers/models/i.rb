require 'shale'

require_relative 'a'
require_relative 'b'
require_relative 'bold'
require_relative 'bom_ref'
require_relative 'express_extref'
require_relative 'express_ref'
require_relative 'module_ref'
require_relative 'sub'
require_relative 'sup'
require_relative 'tt'

class Italic < Shale::Mapper
  attribute :content, Shale::Type::String
  attribute :express_ref, ExpressRef, collection: true
  attribute :express_extref, ExpressExtref, collection: true
  attribute :module_ref, ModuleRef, collection: true
  attribute :bom_ref, BomRef, collection: true
  attribute :i, Italic, collection: true
  attribute :b, B, collection: true
  attribute :sub, Sub, collection: true
  attribute :sup, Sup, collection: true
  attribute :tt, Tt, collection: true
  attribute :bold, Bold, collection: true
  attribute :a, A, collection: true

  xml do
    root 'i'

    map_content to: :content
    map_element 'express_ref', to: :express_ref
    map_element 'express_extref', to: :express_extref
    map_element 'module_ref', to: :module_ref
    map_element 'bom_ref', to: :bom_ref
    map_element 'i', to: :i
    map_element 'b', to: :b
    map_element 'sub', to: :sub
    map_element 'sup', to: :sup
    map_element 'tt', to: :tt
    map_element 'bold', to: :bold
    map_element 'a', to: :a
  end
end
