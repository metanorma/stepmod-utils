# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class SchemaDiag < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          treat_children(node, state).strip
        end
      end
      Coradoc::Input::Html::Converters.register :schema_diag, SchemaDiag.new
    end
  end
end
