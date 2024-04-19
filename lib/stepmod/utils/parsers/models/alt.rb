require "shale"

class Alt < Shale::Mapper
  attribute :content, Shale::Type::String

  xml do
    root 'alt'

    map_content to: :content
  end
end
