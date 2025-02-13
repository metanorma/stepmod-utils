# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Dl < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          cleaned_node = cleanup_trash_tags(node.clone)
          treat_children(cleaned_node, state)
        end

        private

        # https://github.com/metanorma/stepmod-utils/issues/48#issuecomment-784000377
        # For simplicity reasons and so that we don't depend on the CVS repository's updates, we directly converting:
        # <dt></dt><dd>a3ma &#160; : &#160; annotated 3d model assembly</dd> into a3ma:: annotated 3d model assembly
        def cleanup_trash_tags(node)
          inner_content = node.inner_html
          inner_content
            .gsub!(/<dt><\/dt>\s*?<dd>(.+?) &#xA0; : &#xA0; (.+?)<\/dd>/) do
              "<dt>#{$1}</dt><dd>#{$2}</dd>"
            end
          node.inner_html = inner_content
          node
        end

        Coradoc::Input::HTML::Converters.register :dl, Dl.new
      end
    end
  end
end
