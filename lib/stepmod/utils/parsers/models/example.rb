require "shale"

require_relative "a"
require_relative "b"
require_relative "bigeqn"
require_relative "bold"
require_relative "bom_ref"
require_relative "dl"
require_relative "eqn"
require_relative "express_extref"
require_relative "express_ref"
require_relative "figure"
require_relative "i"
require_relative "module_ref"
require_relative "ol"
require_relative "p"
require_relative "screen"
require_relative "sub"
require_relative "sup"
require_relative "table"
require_relative "tt"
require_relative "ul"

module Stepmod
  module Utils
    module Parsers
      module Models
        class Example < Shale::Mapper
          attribute :content, Shale::Type::String
          attribute :id, Shale::Type::Value
          attribute :number, Shale::Type::String
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
          attribute :p, P, collection: true
          attribute :ul, Ul, collection: true
          attribute :ol, Ol, collection: true
          attribute :dl, Dl, collection: true
          attribute :screen, Screen, collection: true
          attribute :figure, Figure, collection: true
          attribute :table, Table, collection: true
          attribute :eqn, Eqn, collection: true
          attribute :bigeqn, Bigeqn, collection: true

          xml do
            root "example"

            map_content to: :content
            map_attribute "id", to: :id
            map_attribute "number", to: :number
            map_element "express_ref", to: :express_ref
            map_element "express_extref", to: :express_extref
            map_element "module_ref", to: :module_ref
            map_element "bom_ref", to: :bom_ref
            map_element "i", to: :i
            map_element "b", to: :b
            map_element "sub", to: :sub
            map_element "sup", to: :sup
            map_element "tt", to: :tt
            map_element "bold", to: :bold
            map_element "a", to: :a
            map_element "p", to: :p
            map_element "ul", to: :ul
            map_element "ol", to: :ol
            map_element "dl", to: :dl
            map_element "screen", to: :screen
            map_element "figure", to: :figure
            map_element "table", to: :table
            map_element "eqn", to: :eqn
            map_element "bigeqn", to: :bigeqn
          end
        end
      end
    end
  end
end
