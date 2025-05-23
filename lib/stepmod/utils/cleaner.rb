require "coradoc/input/html/cleaner"

module Stepmod
  module Utils
    class Cleaner < Coradoc::Input::Html::Cleaner
      def tidy(string)
        super
          .gsub(/^ +/, "")
          .gsub(/\*\s([,.])/, '*\1') # remove space between * and comma or dot.
      end

      # Find non-asterisk content that is enclosed by two or
      # more asterisks. Ensure that only one whitespace occurs
      # in the border area.
      # Same for underscores and brackets.
      def clean_tag_borders(string)
        patterns = {
          /\s?\*{2,}.*?\*{2,}\s?/ => "**",
          /\s?_{2,}.*?_{2,}\s?/   => "__",
          /\s?~{2,}.*?~{2,}\s?/   => "~~",
        }

        result = string.dup
        patterns.each do |pattern, value|
          result = result.gsub(pattern) do |match|
            preserve_border_whitespaces(match,
                                        default_border: Coradoc::Input::Html.config.tag_border) do
              match.strip.sub(" #{value}", value).sub("#{value} ", value)
            end
          end
        end

        result = result.gsub(/\s?\[.*?\]\s?/) do |match|
          preserve_border_whitespaces(match) do
            match.strip.sub("[ ", "[").sub(" ]", "[")
          end
        end
        result
      end
    end
  end
end
