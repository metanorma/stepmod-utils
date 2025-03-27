# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExpressNote < Stepmod::Utils::Converters::Base
        def to_coradoc(node, state = {})
          <<~TEMPLATE

            (*"#{state[:schema_and_entity]}.__note"
            #{treat_children(node, state).strip}
            *)
          TEMPLATE
        end
      end

      Coradoc::Input::Html::Converters.register :express_note, ExpressNote.new
    end
  end
end
