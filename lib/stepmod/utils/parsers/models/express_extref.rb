require 'shale'

class ExpressExtref < Shale::Mapper
  attribute :linkend, Shale::Type::String
  attribute :standard, Shale::Type::String

  xml do
    root 'express_extref'

    map_attribute 'linkend', to: :linkend
    map_attribute 'standard', to: :standard
  end
end
