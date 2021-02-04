# frozen_string_literal: true

module Stepmod
  module Utils
    module Converters
      class ExpressG < ReverseAdoc::Converters::Base
        def convert(node, state = {})
          node.children.map do |child|
            next unless child.name == 'imgfile'

            parse_to_svg_reference(child['file'])
          end.join("\n")
        end

        private

        def parse_to_svg_reference(file)
          return '' unless File.file?(file)

          image_document = Nokogiri::XML(File.read(file))
          svg_path = File.basename(image_document.xpath('//img').first['src'], '.*')
          <<~SVGMAP
            [.svgmap]
            ====
            image::#{svg_path}.svg[]

            #{image_document.xpath('//img.area').map {|n| schema_reference(n['href']) }.join("\n")}
            ====
          SVGMAP
        end

        def schema_reference(xml_path)
          schema_name = File.basename(xml_path, '.*')
          "* <<express:#{schema_name},#{schema_name}>>; #{xml_path}"
        end
      end

      ReverseAdoc::Converters.register 'express-g', ExpressG.new
    end
  end
end
