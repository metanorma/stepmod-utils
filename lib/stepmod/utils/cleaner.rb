require "reverse_adoc/cleaner"

module Stepmod
  module Utils
    class Cleaner < ReverseAdoc::Cleaner
      def tidy(string)
        super.gsub(/^ +/, "")
      end
    end
  end
end
