require 'shale'

class Refpath < Shale::Mapper
  attribute :content, StringWithoutIndent
  attribute :space, Shale::Type::Value

  xml do
    root 'refpath'

    map_content to: :content
    map_attribute 'space', to: :space
  end
end
