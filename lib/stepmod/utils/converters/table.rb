# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Table < Stepmod::Utils::Converters::Base
        def self.pattern(state, id)
          if state[:schema_and_entity].nil?
            raise StandardError.new("[table]: no state given, #{id}")
          end

          schema = state[:schema_and_entity].split(".").first
          "table-#{schema}-#{id}"
        end

        def convert(node, state = {})
          # If we want to skip this node
          return "" if state[:no_notes_examples]

          id = node["id"]
          anchor = id ? "[[table-#{self.class.pattern(state, id)}]]\n" : ""
          title = node["caption"].to_s
          title = ".#{title}\n" unless title.empty?
          attrs = style(node)

          <<~TABLE


            #{anchor}#{attrs}#{title}|===
            #{treat_children(node, state.merge(inside_table: true))}
            |===
          TABLE
        end

        def frame(node)
          case node["frame"]
          when "void"
            "frame=none"
          when "hsides"
            "frame=topbot"
          when "vsides"
            "frame=sides"
          when "box", "border"
            "frame=all"
          end
        end

        def rules(node)
          case node["rules"]
          when "all"
            "rules=all"
          when "rows"
            "rules=rows"
          when "cols"
            "rules=cols"
          when "none"
            "rules=none"
          end
        end

        def style(node)
          width = "width=#{node['width']}" if node["width"]
          attrs = []
          frame_attr = frame(node)
          rules_attr = rules(node)
          attrs += width if width
          attrs += frame_attr if frame_attr
          attrs += rules_attr if rules_attr
          return "" if attrs.empty?

          "[#{attrs.join(',')}]\n"
        end
      end

      ReverseAdoc::Converters.register :table, Table.new
    end
  end
end
