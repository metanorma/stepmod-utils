require "shale"

class BomRef < Shale::Mapper
  attribute :content, Shale::Type::String
  attribute :linkend, Shale::Type::String

  xml do
    root 'bom_ref'

    map_content to: :content
    map_attribute 'linkend', to: :linkend
  end
end
