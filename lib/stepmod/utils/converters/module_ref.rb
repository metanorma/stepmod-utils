# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ModuleRef < Stepmod::Utils::Converters::Base
        def to_coradoc(node, _state = {})
          link_end = node["linkend"].to_s.split(":")
          ref_id = link_end.last
          text = node.text.gsub(/\s/, " ").squeeze(" ").strip
          schema = link_end.first

          if _state[:schema_and_entity].nil?
            # puts "[module_ref] setting node state #{link_end.inspect}"
            _state[:schema_and_entity] = schema
          end

          case link_end[1]
          when "1_scope", "introduction"
            # When we see this:
            # <module_ref linkend="functional_usage_view:1_scope">Functional usage view</module_ref>
            # <module_ref linkend="part_definition_relationship:introduction"> Part definition relationship</module_ref>
            # We convert into:
            # <<express:functional_usage_view>>
            # <<express:part_definition_relationship>>

            "<<express:#{schema}>>"

          when "3_definition"
            # #23:
            # When we see this:
            # <module_ref linkend="product_as_individual:3_definition">individual products</module_ref>
            # We convert to this:
            # {{individual products}}

            "{{#{text}}}"

          when "4_types"
            # When we see this:
            # <module_ref linkend="activity_method_assignment:4_types">activity_method_item</module_ref>
            # We convert to this:
            # <<express:activity_method_assignment.activity_method_item>>
            "<<express:#{[schema, text].join('.')},#{text}>>"
          when "4_entities", "f_usage_guide"
            case link_end[2]
            when "figure"
              # When we see this:
              # <module_ref linkend="assembly_module_design:4_entities:figure:pudv">Figure 1</module_ref>
              # We convert to this:
              # <<figure-pudv>>
              # When we see this (without a number):
              # <module_ref linkend="assembly_module_design:4_entities:figure:pudv">This Figure</module_ref>
              # We convert to this:
              # <<figure-pudv,This Figure>>
              create_ref(Figure.pattern(_state, ref_id), text)
            when "table"
              # When we see this:
              # <module_ref linkend="independent_property_definition:4_entities:table:T1">Table 1</module_ref>
              # We convert to this:
              # <<table-T1>>
              # When we see this (without a number):
              # <module_ref linkend="independent_property_definition:4_entities:table:T1">This Table</module_ref>
              # We convert to this:
              # <<table-T1,This Table>>
              create_ref(Table.pattern(_state, ref_id), text)
            end
          else
            puts "[module_ref]: encountered unknown <module_ref> tag, #{link_end.join(':')}"
            raise StandardError.new("[module_ref]: encountered unknown <module_ref> tag, #{link_end.join(':')}")
          end

          # puts "[module_ref] #{result}"
        end

        private

        def create_ref(link, text)
          if number_with_optional_prefix?(text)
            "<<#{link}>>"
          else
            "<<#{link},#{text}>>"
          end
        end

        def number_with_optional_prefix?(text)
          /.*?\s*\(?\d+\)?/.match(text)
        end
      end
      Coradoc::Input::Html::Converters.register :module_ref, ModuleRef.new
    end
  end
end
