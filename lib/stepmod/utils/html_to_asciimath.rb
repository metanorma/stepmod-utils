module Stepmod
  module Utils
    class HtmlToAsciimath
      def call(input)
        return input if input.nil? || input.empty?

        to_asciimath = Nokogiri::HTML.fragment(input, "UTF-8")

        to_asciimath.css("i").each do |math_element|
          # puts "HTML MATH!!  #{math_element.to_xml}"
          # puts "HTML MATH!!  #{math_element.text}"
          decoded = text_to_asciimath(math_element.text)
          case decoded.length
          when 1..12
            # puts "(#{math_element.text} to => #{decoded})"
            math_element.replace "stem:[#{decoded}]"
          when 0
            math_element.remove
          else
            math_element.replace "_#{decoded}_"
          end
        end

        to_asciimath.css("sub").each do |math_element|
          case math_element.text.length
          when 0
            math_element.remove
          else
            math_element.replace "~#{text_to_asciimath(math_element.text)}~"
          end
        end

        to_asciimath.css("sup").each do |math_element|
          case math_element.text.length
          when 0
            math_element.remove
          else
            math_element.replace "^#{text_to_asciimath(math_element.text)}^"
          end
        end

        to_asciimath.css("ol").each do |element|
          element.css("li").each do |li|
            li.replace ". #{li.text}"
          end
        end

        to_asciimath.css("ul").each do |element|
          element.css("li").each do |li|
            li.replace "* #{li.text}"
          end
        end

        # Replace sans-serif font with monospace
        to_asciimath.css('font[style*="sans-serif"]').each do |x|
          x.replace "`#{x.text}`"
        end

        html_entities_to_stem(
          to_asciimath.children.to_s.gsub(/\]stem:\[/, "").gsub(/<\/?[uo]l>/,
                                                                ""),
        )
      end

      def text_to_asciimath(text)
        html_entities_to_asciimath(text.decode_html)
      end

      def html_entities_to_asciimath(x)
        x.gsub("&alpha;", "alpha")
         .gsub("&beta;", "beta")
         .gsub("&gamma;", "gamma")
         .gsub("&Gamma;", "Gamma")
         .gsub("&delta;", "delta")
         .gsub("&Delta;", "Delta")
         .gsub("&epsilon;", "epsilon")
         .gsub("&varepsilon;", "varepsilon")
         .gsub("&zeta;", "zeta")
         .gsub("&eta;", "eta")
         .gsub("&theta;", "theta")
         .gsub("&Theta;", "Theta")
         .gsub("&vartheta;", "vartheta")
         .gsub("&iota;", "iota")
         .gsub("&kappa;", "kappa")
         .gsub("&lambda;", "lambda")
         .gsub("&Lambda;", "Lambda")
         .gsub("&mu;", "mu")
         .gsub("&nu;", "nu")
         .gsub("&xi;", "xi")
         .gsub("&Xi;", "Xi")
         .gsub("&pi;", "pi")
         .gsub("&Pi;", "Pi")
         .gsub("&rho;", "rho")
         .gsub("&beta;", "beta")
         .gsub("&sigma;", "sigma")
         .gsub("&Sigma;", "Sigma")
         .gsub("&tau;", "tau")
         .gsub("&upsilon;", "upsilon")
         .gsub("&phi;", "phi")
         .gsub("&Phi;", "Phi")
         .gsub("&varphi;", "varphi")
         .gsub("&chi;", "chi")
         .gsub("&psi;", "psi")
         .gsub("&Psi;", "Psi")
         .gsub("&omega;", "omega")
         .gsub("&#967", "χ")
         .gsub("&#215", "×")
         .gsub("&#931", "Σ")
         .gsub("&#961", "ρ")
         .gsub("&#963", "σ")
         .gsub("&#955", "λ")
         .gsub("&#964", "τ")
         .gsub("&#8706", "∂")
         .gsub("&#8804", "≤")
         .gsub("&#8805", "≥")
      end

      def html_entities_to_stem(x)
        x.gsub("&alpha;", "stem:[alpha]")
         .gsub("&beta;", "stem:[beta]")
         .gsub("&gamma;", "stem:[gamma]")
         .gsub("&Gamma;", "stem:[Gamma]")
         .gsub("&delta;", "stem:[delta]")
         .gsub("&Delta;", "stem:[Delta]")
         .gsub("&epsilon;", "stem:[epsilon]")
         .gsub("&varepsilon;", "stem:[varepsilon]")
         .gsub("&zeta;", "stem:[zeta]")
         .gsub("&eta;", "stem:[eta]")
         .gsub("&theta;", "stem:[theta]")
         .gsub("&Theta;", "stem:[Theta]")
         .gsub("&vartheta;", "stem:[vartheta]")
         .gsub("&iota;", "stem:[iota]")
         .gsub("&kappa;", "stem:[kappa]")
         .gsub("&lambda;", "stem:[lambda]")
         .gsub("&Lambda;", "stem:[Lambda]")
         .gsub("&mu;", "stem:[mu]")
         .gsub("&nu;", "stem:[nu]")
         .gsub("&xi;", "stem:[xi]")
         .gsub("&Xi;", "stem:[Xi]")
         .gsub("&pi;", "stem:[pi]")
         .gsub("&Pi;", "stem:[Pi]")
         .gsub("&rho;", "stem:[rho]")
         .gsub("&beta;", "stem:[beta]")
         .gsub("&sigma;", "stem:[sigma]")
         .gsub("&Sigma;", "stem:[Sigma]")
         .gsub("&tau;", "stem:[tau]")
         .gsub("&upsilon;", "stem:[upsilon]")
         .gsub("&phi;", "stem:[phi]")
         .gsub("&Phi;", "stem:[Phi]")
         .gsub("&varphi;", "stem:[varphi]")
         .gsub("&chi;", "stem:[chi]")
         .gsub("&psi;", "stem:[psi]")
         .gsub("&Psi;", "stem:[Psi]")
         .gsub("&omega;", "stem:[omega]")
      end
    end
  end
end
