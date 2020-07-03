module Stepmod
  module Utils

    class Bibdata

      DOCNUMBER = 10303

      attr_accessor *%w(
        type doctype part title_en title_fr version language pub_year pub_date
      )

      def initialize(document:)
        return nil unless document.is_a?(Nokogiri::XML::Element)

        # module, resource, application_protocol, business_object_model
        @type = document.name

        raise 'UnknownFileError' unless %w(module resource application_protocol business_object_model).include?(@type)

        @doctype = document['status']
        @part = document['part']
        @title_en = document['title'] ||
          document['name'].gsub('_', ' ').capitalize.gsub('2d','2D').gsub('3d','3D')
        @title_fr = document['name.french']
        @version = document['version']
        @language = document['language']

        # Some publication.year contains month...
        @pub_year = document['publication.year'].split('-').first
        @pub_date = document['publication.date']

        puts to_mn_adoc

        return self
        # <module
        #    name="security_classification"
        #    name.french="Classification des s&#233;curit&#233;s"
        #    part="1015"
        #    wg.number="1095"
        #    wg.number.supersedes="720"
        #    wg.number.arm.supersedes="1096"
        #    wg.number.arm="3221"
        #    wg.number.mim="1097"
        #    checklist.internal_review="2133"
        #    checklist.project_leader="2134"
        #    checklist.convener="2135"
        #    version="1"
        #    status="TS"
        #    language="E"
        #    publication.year="2004"
        #     publication.date="2004-12-01"
        #    published="y"
        #    rcs.date="$Date: 2009/11/02 10:59:35 $"
        #    rcs.revision="$Revision: 1.26 $"
        #   development.folder="dvlp"
        # >

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
        "Industrial automation systems and integration -- Product data representation and exchange -- Part #{part}: #{part_title}"
      end

      def anchor
        docid.gsub('/', '-').gsub(' ', '_').gsub(':', '_')
      end

      def to_mn_adoc
        if title_en
          "* [[[ISO#{DOCNUMBER}-#{part},#{docid}]]], _#{full_title}_"
        else
          "* [[[ISO#{DOCNUMBER}-#{part},#{docid}]]]"
        end
      end

    end

  end
end

