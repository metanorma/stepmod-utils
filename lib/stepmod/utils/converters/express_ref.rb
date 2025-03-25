# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExpressRef < Stepmod::Utils::Converters::Base
        def to_coradoc(node, _state = {})
          " *#{node['linkend'].to_s.split('.').last}* "
        end
      end
      Coradoc::Input::Html::Converters.register :express_ref, ExpressRef.new
    end
  end
end
