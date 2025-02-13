module Stepmod
  module Utils
    module Converters
      class ExtDescription < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          state = state.merge(schema_name: node["linkend"],
                              non_flanking_whitesapce: true)
          child_text = treat_children(node, state).strip

          <<~TEMPLATE
            (*"#{node['linkend']}"
            #{child_text}
            *)
          TEMPLATE
        end
      end
      Coradoc::Input::HTML::Converters.register :ext_description, ExtDescription.new
    end
  end
end
