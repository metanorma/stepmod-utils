# frozen_string_literal: true

require "stepmod/utils/converters/synonym"

module Stepmod
  module Utils
    module Converters
      class Uof < ReverseAdoc::Converters::Base
        def convert(_node, _state = {})
          # WARNING: <uof> tag content is deprecated
          ""

          #
          # <<~TEXT
          # === #{node['name'].strip}

          # <ISO 10303 application module> #{treat_children(node, state).strip}
          # TEXT
        end
      end

      ReverseAdoc::Converters.register :uof, Uof.new
    end
  end
end
