module Stepmod
  module Utils
    class ExpressBibdata
      DOCNUMBER = 10303

      attr_accessor *%w(
        type doctype part title_en version pub_year pubid published_info
      )

      def initialize(schema:)
        # module, resource, application_protocol, business_object_model
        # @type = document.name

        # raise "UnknownFileError" unless %w(module resource
        #                                    application_protocol business_object_model).include?(@type)

        @published_info = extract_remarks(schema, "__published_in")&.first
        @schema = schema

        if !published_info.nil?
          @pubid = Pubid::Iso::Identifier.parse(published_info)

          @part = pubid.part
          @version = pubid.edition
          @pub_year = pubid.year
        elsif !schema.version.nil?
          @part = schema.version.items.find { |i| i.name == "part" }.value
          @version = schema.version.items.find { |i| i.name == "part" }.value
          @pub_year = schema.version.items.find { |i| i.name == "part" }.value
        else
          raise "PublishedInfoNotFound" if published_info.nil?
        end

        @doctype = extract_remarks(schema, "__status")&.first
        self
      end

      def extract_remarks(schema, remark_name)
        schema.remark_items.find { |remark| remark.id == remark_name }&.remarks
      end

      def title_en
        @title_en ||= extract_remarks(@schema, "__title").first
                                                         .gsub("_", " ")
                                                         .capitalize
                                                         .gsub("2d", "2D")
                                                         .gsub("3d", "3D")
      end

      def docid
        no_date = case doctype
                  when "IS"
                    "ISO #{DOCNUMBER}-#{part}"
                  when "WD"
                    "ISO/WD #{DOCNUMBER}-#{part}"
                  when "CD"
                    "ISO/CD #{DOCNUMBER}-#{part}"
                  when "DIS"
                    "ISO/DIS #{DOCNUMBER}-#{part}"
                  when "FDIS"
                    "ISO/FDIS #{DOCNUMBER}-#{part}"
                  when "TS"
                    "ISO/TS #{DOCNUMBER}-#{part}"
                  when "CD-TS"
                    "ISO/CD TS #{DOCNUMBER}-#{part}"
                  else
                    "UNKNOWN DOCTYPE: (#{doctype})"
                  end

        if pub_year
          "#{no_date}:#{pub_year}"
        else
          no_date
        end
      end

      def part_title
        case part
        when [200..299]
          "Application protocol: #{title_en}"
        when [300..399]
          "Abstract test suite: #{title_en}"
        when [400..499]
          "Application module: #{title_en}"
        when [500..599]
          "Application interpreted construct: #{title_en}"
        when [1000..1799]
          "Application module: #{title_en}"
        else
          title_en
        end
      end

      def full_title
        "Industrial automation systems and integration -- Product data" \
          " representation and exchange -- Part #{part}: #{part_title}"
      end

      def anchor
        docid.gsub("/", "-").gsub(" ", "_").gsub(":", "_")
      end

      def to_mn_adoc
        if title_en
          "* [[[#{anchor},#{docid}]]], _#{full_title}_"
        else
          "* [[[#{anchor},#{docid}]]]"
        end
      end
    end
  end
end
