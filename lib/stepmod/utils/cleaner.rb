require "coradoc/input/html/cleaner"

module Stepmod
  module Utils
    class Cleaner < Coradoc::Input::HTML::Cleaner
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
        result = string.gsub(/\s?\*{2,}.*?\*{2,}\s?/) do |match|
          preserve_border_whitespaces(match, default_border: Coradoc::Input::HTML.config.tag_border) do
            match.strip.sub("** ", "**").sub(" **", "**")
          end
        end

        result = result.gsub(/\s?_{2,}.*?_{2,}\s?/) do |match|
          preserve_border_whitespaces(match, default_border: Coradoc::Input::HTML.config.tag_border) do
            match.strip.sub("__ ", "__").sub(" __", "__")
          end
        end
  
        result = result.gsub(/\s?~{2,}.*?~{2,}\s?/) do |match|
          preserve_border_whitespaces(match, default_border: Coradoc::Input::HTML.config.tag_border) do
            match.strip.sub("~~ ", "~~").sub(" ~~", "~~")
          end
        end
  
        result.gsub(/\s?\[.*?\]\s?/) do |match|
          preserve_border_whitespaces(match) do
            match.strip.sub("[ ", "[").sub(" ]", "]")
          end
        end
      end
    end
  end
end
