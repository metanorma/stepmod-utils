require "plurimath"
require "stepmod/utils"

module Stepmod
  module Utils
    class EquationLogger
      attr_accessor :anchor,
                    :document,
                    :equation,
                    :equation_converted,
                    :equation_converted_with_bold_and_italics

      def initialize
        @logger = Logger.new(logger_file_path)
      end

      def log
        Stepmod::Utils.increment_eqn_counter
        @logger.info do
          <<~MESSAGE

            =================== Equation #{Stepmod::Utils.eqn_counter} Start ===================
            Document: #{document}
            Nearest Anchor: #{anchor}

            Formula (original):
            #{equation}

            ------------------

            Status: #{valid_asciimath?(equation_converted)}
            Formula (asciimath):
            #{equation_converted}

            ------------------

            Status: #{valid_asciimath?(equation_converted_with_bold_and_italics)}
            Formula (asciimath with bold and italics included):
            #{equation_converted_with_bold_and_italics}

            =================== Equation #{Stepmod::Utils.eqn_counter} End ===================


          MESSAGE
        end
      end

      private

      def logger_file_path
        File.join(Stepmod::Utils.eqn_log_dir, "stepmod-utils.log.txt")
      end

      def valid_asciimath?(equation)
        extracted_equation = extract_equation_from_stem(equation)
        Plurimath::Math.parse(extracted_equation, :asciimath).to_mathml
        "valid"
      rescue StandardError
        "invalid"
      end

      def extract_equation_from_stem(stem)
        stem.gsub(/\[stem\]|\+\+\+\+/, "").strip
      end
    end
  end
end
