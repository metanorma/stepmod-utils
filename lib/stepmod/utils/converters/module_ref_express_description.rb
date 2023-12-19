
require "stepmod/utils/converters/figure"
require "stepmod/utils/converters/table"

module Stepmod
  module Utils
    module Converters
      class ModuleRefExpressDescription < Stepmod::Utils::Converters::Base
        def convert(node, _state = {})
          link_end = node["linkend"].to_s.split(":")
          ref_id = link_end.last
          parts = link_end.last.split(".")
          text = node.text.gsub(/\s/, " ").squeeze(" ").strip

          # puts "linkend #{node["linkend"]}"

          result = case link_end[1]
          when "1_scope", "introduction"
            # When we see this:
            # <module_ref linkend="functional_usage_view:1_scope">Functional usage view</module_ref>
            # <module_ref linkend="part_definition_relationship:introduction"> Part definition relationship</module_ref>
            # We convert into:
            # <<express:functional_usage_view>>
            # <<express:part_definition_relationship>>

            "<<express:#{link_end.first}>>"

          when "3_definition"
            # #23:
            # When we see this:
            # <module_ref linkend="product_as_individual:3_definition">individual products</module_ref>
            # We convert to this:
            # {{individual products}}

            "{{#{text}}}"

          when "4_types"
            # ISO 10303-2 does not contain TYPEs, ignore
            ""
          when "4_entities", "f_usage_guide"
            # ISO 10303-2 does not contain figures and tables, ignore
            ""
          else
            puts "[module_ref_express_description]: encountered unknown <module_ref> tag, #{link_end.join(":")}"
            raise StandardError.new("[module_ref_express_description]: encountered unknown <module_ref> tag, #{link_end.join(":")}")
          end

          # puts "[module_ref] #{result}"
          result
        end
      end
      ReverseAdoc::Converters.register :module_ref,
                                       ModuleRefExpressDescription.new
    end
  end
end
