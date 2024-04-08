require 'shale'

class ExpressRef < Shale::Mapper
  attribute :content, Shale::Type::String
  attribute :linkend, Shale::Type::String

  xml do
    root 'express_ref'

    map_content to: :content
    map_attribute 'linkend', to: :linkend
  end
end
