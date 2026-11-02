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
      # Same for underscores and brackets. A missing border is added, except
      # next to a word character: unconstrained markup may sit inside a word.
      def clean_tag_borders(string)
        patterns = {
          /\s?\*{2,}.*?\*{2,}\s?/ => "**",
          /\s?_{2,}.*?_{2,}\s?/   => "__",
          /\s?~{2,}.*?~{2,}\s?/   => "~~",
        }

        result = string.dup
        patterns.each do |pattern, value|
          result = result.gsub(pattern) do |match|
            border_tags(match, Regexp.last_match) do
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

      private

      # Like preserve_border_whitespaces, but a border is only invented where
      # the neighbouring character is not part of a word.
      def border_tags(match, matched)
        return match if /\A\s*\Z/.match?(match)

        invent = !/[\[(\])]/.match?(match)
        start = match[/\A\s*/]
        finish = match[/\s*\Z/]
        start = border(matched.pre_match[-1]) if start.empty? && invent
        finish = border(matched.post_match[0]) if finish.empty? && invent

        start + yield + finish
      end

      def border(neighbour)
        neighbour&.match?(/\w/) ? "" : Coradoc::Input::Html.config.tag_border
      end
    end
  end
end
