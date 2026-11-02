# frozen_string_literal: true

require_relative "figure"

module Stepmod
  module Utils
    module Converters
      class A < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
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
            href = figure_anchor(href, state) || href
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

        # A reference to a figure must use the id the figure is given by
        # Figure.pattern, or the link does not resolve.
        def figure_anchor(href, state)
          return unless state[:schema_and_entity] || state[:schema_name]

          figure_id = href[/\Afigure[_-](.+)\z/, 1]
          figure_id = href if figure_id.nil? &&
            Array(state[:figure_ids]).include?(href)
          Figure.pattern(state, figure_id) if figure_id
        end

        def number_with_optional_prefix?(name)
          /.*?\s*\(?\d+\)?/.match(name)
        end
      end

      Coradoc::Input::Html::Converters.register :a, A.new
    end
  end
end
