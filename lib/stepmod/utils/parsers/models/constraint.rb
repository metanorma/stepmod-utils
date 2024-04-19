require "shale"

class Constraint < Shale::Mapper
  attribute :content, Shale::Type::String

  xml do
    root 'constraint'

    map_content to: :content
  end
end
