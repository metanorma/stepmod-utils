# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class Bypass < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          treat_children(node, state)
        end
      end

      ReverseAdoc::Converters.register :document, Bypass.new
      ReverseAdoc::Converters.register :html,     Bypass.new
      ReverseAdoc::Converters.register :body,     Bypass.new
      ReverseAdoc::Converters.register :span,     Bypass.new
      ReverseAdoc::Converters.register :thead,    Bypass.new
      ReverseAdoc::Converters.register :tbody,    Bypass.new
      ReverseAdoc::Converters.register :tfoot,    Bypass.new
      ReverseAdoc::Converters.register :abbr, Bypass.new
      ReverseAdoc::Converters.register :acronym,    Bypass.new
      ReverseAdoc::Converters.register :address,    Bypass.new
      ReverseAdoc::Converters.register :applet, Bypass.new
      ReverseAdoc::Converters.register :map, Bypass.new
      ReverseAdoc::Converters.register :area, Bypass.new
      ReverseAdoc::Converters.register :bdi,    Bypass.new
      ReverseAdoc::Converters.register :bdo,    Bypass.new
      ReverseAdoc::Converters.register :big,    Bypass.new
      ReverseAdoc::Converters.register :button,    Bypass.new
      ReverseAdoc::Converters.register :canvas,    Bypass.new
      ReverseAdoc::Converters.register :data, Bypass.new
      ReverseAdoc::Converters.register :datalist, Bypass.new
      ReverseAdoc::Converters.register :del,    Bypass.new
      ReverseAdoc::Converters.register :ins,    Bypass.new
      ReverseAdoc::Converters.register :dfn,    Bypass.new
      ReverseAdoc::Converters.register :dialog, Bypass.new
      ReverseAdoc::Converters.register :embed, Bypass.new
      ReverseAdoc::Converters.register :fieldset, Bypass.new
      ReverseAdoc::Converters.register :font, Bypass.new
      ReverseAdoc::Converters.register :footer, Bypass.new
      ReverseAdoc::Converters.register :form, Bypass.new
      ReverseAdoc::Converters.register :frame, Bypass.new
      ReverseAdoc::Converters.register :frameset, Bypass.new
      ReverseAdoc::Converters.register :header,    Bypass.new
      ReverseAdoc::Converters.register :iframe,    Bypass.new
      ReverseAdoc::Converters.register :input,    Bypass.new
      ReverseAdoc::Converters.register :label,    Bypass.new
      ReverseAdoc::Converters.register :legend, Bypass.new
      ReverseAdoc::Converters.register :main,    Bypass.new
      ReverseAdoc::Converters.register :menu,    Bypass.new
      ReverseAdoc::Converters.register :menulist, Bypass.new
      ReverseAdoc::Converters.register :meter, Bypass.new
      ReverseAdoc::Converters.register :nav, Bypass.new
      ReverseAdoc::Converters.register :noframes,    Bypass.new
      ReverseAdoc::Converters.register :noscript,    Bypass.new
      ReverseAdoc::Converters.register :object, Bypass.new
      ReverseAdoc::Converters.register :optgroup, Bypass.new
      ReverseAdoc::Converters.register :option,    Bypass.new
      ReverseAdoc::Converters.register :output,    Bypass.new
      ReverseAdoc::Converters.register :param, Bypass.new
      ReverseAdoc::Converters.register :picture, Bypass.new
      ReverseAdoc::Converters.register :progress, Bypass.new
      ReverseAdoc::Converters.register :ruby, Bypass.new
      ReverseAdoc::Converters.register :rt,    Bypass.new
      ReverseAdoc::Converters.register :rp,    Bypass.new
      ReverseAdoc::Converters.register :s, Bypass.new
      ReverseAdoc::Converters.register :select, Bypass.new
      ReverseAdoc::Converters.register :small, Bypass.new
      ReverseAdoc::Converters.register :span, Bypass.new
      ReverseAdoc::Converters.register :strike, Bypass.new
      ReverseAdoc::Converters.register :details,    Bypass.new
      ReverseAdoc::Converters.register :section,    Bypass.new
      ReverseAdoc::Converters.register :summary,    Bypass.new
      ReverseAdoc::Converters.register :svg, Bypass.new
      ReverseAdoc::Converters.register :template,    Bypass.new
      ReverseAdoc::Converters.register :textarea,    Bypass.new
      ReverseAdoc::Converters.register :track, Bypass.new
      ReverseAdoc::Converters.register :u, Bypass.new
      ReverseAdoc::Converters.register :wbr, Bypass.new
    end
  end
end
