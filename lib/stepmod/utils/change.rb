module Stepmod
  module Utils
    class Change
      def to_h
        self.class::ATTRIBUTES
          .to_h { |name| [name.to_s, public_send(name)] }
          .compact
      end
    end
  end
end
