require "reverse_adoc/cleaner"

module Stepmod
  module Utils
    class Cleaner < ReverseAdoc::Cleaner
      def tidy(string)
        super
          .gsub(/^ +/, "")
          .gsub(/\*\s([,.])/, '*\1') # remove space between * and comma or dot.
      end
    end
  end
end
