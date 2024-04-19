require "shale"

module Stepmod
  module Utils
    module Parsers
      module Models
        class ModuleRef < Shale::Mapper
          attribute :content, Shale::Type::String
          attribute :linkend, Shale::Type::String

          xml do
            root "module_ref"

            map_content to: :content
            map_attribute "linkend", to: :linkend
          end
        end
      end
    end
  end
end
