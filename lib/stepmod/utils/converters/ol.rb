# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Ol < ReverseAsciidoctor::Converters::Base
        def convert(node, state = {})
          id = node['id']
          anchor = id ? "[[#{id}]]\n" : ""
          ol_count = state.fetch(:ol_count, 0) + 1
          attrs = ol_attrs(node)
          res = "\n#{anchor}#{attrs}#{treat_children(node, state.merge(ol_count: ol_count))}"
          res = "\n" + res if node.parent && node.parent.name == 'note'
          res
        end

        def number_style(node)
          style = case node["style"]
                  when "1" then "arabic"
                  when "A" then "upperalpha"
                  when "a" then "loweralpha"
                  when "I" then "upperroman"
                  when "i" then "lowerroman"
                  else
                    nil
                  end
        end

        def ol_attrs(node)
          style = number_style(node)
          reversed = "%reversed" if node["reversed"]
          start = "start=#{node['start']}" if node["start"]
          type = "type=#{node['type']}" if node["type"]
          attrs = []
          attrs << style if style
          attrs << reversed if reversed
          attrs << start if start
          attrs << type if type
          if attrs.empty?
            ""
          else
            "[#{attrs.join(',')}]\n"
          end
        end
      end

      ReverseAsciidoctor::Converters.register :ol, Ol.new
      ReverseAsciidoctor::Converters.register :ul, Ol.new
      ReverseAsciidoctor::Converters.register :dir, Ol.new
    end
  end
end