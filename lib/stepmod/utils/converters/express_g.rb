# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExpressG < Stepmod::Utils::Converters::Base
        def convert(node, state = {})
          node.children.map do |child|
            next unless child.name == "imgfile"

            parse_to_svg_reference(child["file"], state)
          end.join("\n")
        end

        private

        def parse_to_svg_reference(file, state)
          return "" unless File.file?(file)

          image_document = Nokogiri::XML(File.read(file))
          svg_filename = File.basename(image_document.xpath("//img").first["src"],
                                   ".*")
          <<~SVGMAP

            *)
            (*"#{state.fetch(:schema_name)}.__expressg"
            [[#{svg_filename}]]
            [.svgmap]
            ====
            image::#{svg_filename}.svg[]

            #{image_document.xpath('//img.area').map.with_index(1) { |n, i| schema_reference(n['href'], i) }.join("\n")}
            ====
          SVGMAP
        end

        def schema_reference(xml_path, index)
          if /#/.match?(xml_path)
            _, express_path_part = xml_path.split("#")
            "* <<express:#{express_path_part.strip}>>; #{index}"
          else
            schema_name = File.basename(xml_path, ".*")
            "* <<express:#{schema_name.strip}>>; #{index}"
          end
        end
      end

      ReverseAdoc::Converters.register "express-g", ExpressG.new
    end
  end
end
