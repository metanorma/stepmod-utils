# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Table < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          id = node["id"]
          anchor = id ? "[[#{id}]]\n" : ""
          title = node["caption"].to_s
          title = ".#{title}\n" unless title.empty?
          attrs = style(node)
          "\n\n#{anchor}#{attrs}#{title}|===\n#{treat_children(node,
                                                               state)}\n|===\n"
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
