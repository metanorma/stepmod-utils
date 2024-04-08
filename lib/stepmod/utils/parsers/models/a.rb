require 'shale'

require_relative 'b'
require_relative 'bold'
require_relative 'i'
require_relative 'sub'
require_relative 'sup'
require_relative 'tt'

class A < Shale::Mapper
  attribute :content, Shale::Type::String
  attribute :href, Shale::Type::String
  attribute :i, Italic, collection: true
  attribute :b, B, collection: true
  attribute :sub, Sub, collection: true
  attribute :sup, Sup, collection: true
  attribute :tt, Tt, collection: true
  attribute :bold, Bold, collection: true

  xml do
    root 'a'

    map_content to: :content
    map_attribute 'href', to: :href
    map_element 'i', to: :i
    map_element 'b', to: :b
    map_element 'sub', to: :sub
    map_element 'sup', to: :sup
    map_element 'tt', to: :tt
    map_element 'bold', to: :bold
  end
end
