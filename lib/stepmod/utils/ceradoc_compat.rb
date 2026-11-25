# frozen_string_literal: true

require "nokogiri"
require "ceradoc"
require "ceradoc/html"

module Stepmod
  module Utils
    # coradoc 1.x string-mode compatibility over the ceradoc CoreModel
    # engine. The coradoc → coridoc → ceradoc rename (2026-11-25)
    # replaced the dual string/element converter API (to_coradoc +
    # Generator.gen_adoc) with a CoreModel-only converter entry
    # (to_ceradoc). The stepmod converter chain keeps building AsciiDoc
    # fragments as strings; this module restores the string-mode
    # surface on top of the ceradoc engine classes.
    module CeradocCompat
      module_function

      # coradoc 1.x Generator.gen_adoc: flatten mixed string / CoreModel
      # content into AsciiDoc text. CoreModel nodes serialize through
      # the ceradoc-adoc FromCoreModel transform.
      def gen_adoc(content)
        case content
        when Array then content.map { |elem| gen_adoc(elem) }.join("")
        when String, nil then content.to_s
        when Ceradoc::CoreModel::Base
          require "ceradoc/asciidoc"
          Ceradoc::AsciiDoc::Transform::FromCoreModel
            .transform(content).to_adoc
        else
          content.respond_to?(:to_adoc) ? content.to_adoc : content.to_s
        end
      end

      # Prepended to Ceradoc::Html::Converters::Base so every converter
      # in the shared registry answers the coradoc 1.x string-mode
      # surface. Stepmod's own to_coradoc overrides shadow these.
      module StringMode
        # coradoc 1.x Base#convert — the string entry the stepmod
        # converter drive sites invoke via Converters.lookup(...).convert.
        def convert(node, state = {})
          Stepmod::Utils::CeradocCompat.gen_adoc(to_coradoc(node, state))
        end

        # coradoc 1.x engine entry name; ceradoc renamed it to_ceradoc
        # (CoreModel nodes). For ceradoc-native converters this
        # stringifies their CoreModel output; stepmod's string
        # overrides shadow this when they define to_coradoc.
        def to_coradoc(node, state = {})
          Stepmod::Utils::CeradocCompat.gen_adoc(to_ceradoc(node, state))
        end

        # Engine-side name for stepmod's string converters: run the
        # string chain and carry the fragment as literal text so
        # ceradoc's CoreModel collectors can embed it.
        def to_ceradoc(node, state = {})
          result = to_coradoc(node, state)
          if result.is_a?(String)
            Ceradoc::CoreModel::TextElement.new(content: result)
          else
            result
          end
        end

        # coradoc 1.x string mode: children convert to joined text.
        def treat_children(node, state)
          node.children.map { |child| treat(child, state) }.join
        end

        def treat(node, state)
          Stepmod::Utils::Converters.process(node, state)
        end
      end

      Ceradoc::Html::Converters::Base.prepend(StringMode)
    end
  end
end

module Stepmod
  module Utils
    module Converters
      # coradoc 1.x string-mode traversal over the shared ceradoc
      # converter registry (the old Ceradoc::Html::Converters.process).
      def self.process(node, state)
        node = node.to_a if defined?(Nokogiri::XML::NodeSet) &&
          node.is_a?(Nokogiri::XML::NodeSet)
        return node.map { |i| process(i, state) }.join if node.is_a?(Array)

        lookup = Ceradoc::Html::Converters.lookup(node.name)
        lookup.convert(node, state)
      end
    end
  end
end
