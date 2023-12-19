# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class A < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          # require "pry"; binding.pry
          name  = treat_children(node, state)
          href  = node["href"]
          title = extract_title(node)
          id = node["id"] || node["name"]

          id = id&.gsub(/\s/, "")&.gsub(/__+/, "_")

          if /^_Toc\d+$|^_GoBack$/.match? id
            ""
          elsif !id.nil? && !id.empty?
            "[[#{id}]]"
          elsif href.to_s.start_with?("#")
            href = href.sub(/^#/, "").gsub(/\s/, "").gsub(/__+/, "_")
            if name.empty? || number_with_optional_prefix?(name)
              "<<#{href}>>"
            else
              "<<#{href},#{name}>>"
            end
          elsif href.to_s.empty?
            name
          else
            name = title if name.empty?
            href = "link:#{href}" unless href.to_s&.match?(URI::DEFAULT_PARSER.make_regexp)
            link = href
            link += "[#{name}]" unless number_with_optional_prefix?(name)
            " #{link}"
          end
        end

        private

        def number_with_optional_prefix?(name)
          /.*?\s*\(?\d+\)?/.match(name)
        end
      end

      ReverseAdoc::Converters.register :a, A.new
    end
  end
end
