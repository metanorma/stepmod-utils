require "date"
require "nokogiri"
require "relaton/bib"

module Stepmod
  module Utils
    # Converts the STEPmod shared reference lists, data/basic/normrefs.xml
    # and data/basic/bibliography.xml, into one Relaton collection, so that
    # Metanorma can cite any entry by its id.
    #
    # Each entry becomes a Relaton::Bib::ItemData. Its id is the STEPmod id
    # with the list prefix the migrated documents use ("normref_",
    # "bibitem_"), and the raw STEPmod id is kept as a docidentifier of type
    # "STEPmod-id".
    class BibliographyConverter
      COLLECTION_NS = "https://open.ribose.com/relaton-xml".freeze
      DEFAULT_TITLE = "STEPmod bibliography".freeze
      AUTHOR = "ISO/TC 184/SC 4".freeze

      XML_ENTITIES = %w[amp lt gt quot apos].freeze
      DASHES = /\A[\s—–-]+|[\s—–-]+\z/
      ITEM_TYPES = {
        "normref" => "standard",
        "bibitem" => "standard",
        "bibitem.techreport" => "techreport",
        "bibitem.book" => "book",
      }.freeze

      Bib = Relaton::Bib

      attr_reader :title

      # @param normrefs [String, nil] path to normrefs.xml
      # @param bibliography [String, nil] path to bibliography.xml
      # @param title [String, nil] title of the collection
      def initialize(normrefs: nil, bibliography: nil, title: nil)
        @normrefs = normrefs
        @bibliography = bibliography
        @title = title || DEFAULT_TITLE
      end

      # @return [Array<Relaton::Bib::ItemData>]
      def items
        @items ||= read_list(@normrefs, "normref", "//normref") +
          read_list(@bibliography, "bibitem",
                    "//bibitem | //bibitem.techreport | //bibitem.book")
      end

      # @return [String] a relaton-collection XML document
      def to_xml
        doc = Nokogiri::XML::Document.new
        doc.encoding = "UTF-8"
        root = doc.add_child(doc.create_element("relaton-collection",
                                                xmlns: COLLECTION_NS))
        root.add_child(doc.create_element("title", title))
        root.add_child(author_node(doc))
        items.each do |item|
          relation = root.add_child(doc.create_element("relation",
                                                       type: "partOf"))
          relation.add_child(Nokogiri::XML(item.to_xml, &:noblanks).root)
        end
        doc.to_xml
      end

      private

      def author_node(doc)
        contributor = doc.create_element("contributor")
        contributor.add_child(doc.create_element("role", type: "author"))
        org = contributor.add_child(doc.create_element("organization"))
        org.add_child(doc.create_element("name", AUTHOR))
        contributor
      end

      def read_list(path, prefix, xpath)
        return [] unless path

        seen = {}
        parse(path).xpath(xpath).filter_map do |node|
          raw_id = node["id"]
          id = "#{prefix}_#{sanitize_id(raw_id)}"
          if seen[id]
            log(path, "duplicate id #{raw_id.inspect} skipped")
            next
          end

          seen[id] = true
          build_item(node, id, raw_id)
        end
      end

      def log(path, message)
        warn "[stepmod-utils] #{path}: #{message}"
      end

      # The DTD that declares the HTML entities is not available, so resolve
      # them before the parse.
      # An unknown entity would be dropped silently by the parser, so it is
      # reported and kept as text.
      def parse(path)
        xml = File.read(path, encoding: "UTF-8")
        xml = xml.gsub(/&([a-zA-Z][a-zA-Z0-9]*);/) do |match|
          name = Regexp.last_match(1)
          next match if XML_ENTITIES.include?(name)

          resolve_entity(name) || unknown_entity(path, match)
        end
        Nokogiri::XML(xml, &:nonet)
      end

      def resolve_entity(name)
        codepoint = entity_lookup[name]
        [codepoint].pack("U") if codepoint
      end

      def unknown_entity(path, match)
        log(path, "unknown entity #{match} kept as text")
        "&amp;#{match[1..]}"
      end

      def entity_lookup
        @entity_lookup ||= Nokogiri::HTML4::EntityLookup.new
      end

      def sanitize_id(raw_id)
        raw_id.to_s.gsub(/[^\w.-]+/, "_")
      end

      def build_item(node, id, raw_id)
        ref = node.at("./stdref") || node
        Bib::ItemData.new(
          id: id,
          type: ITEM_TYPES[node.name],
          docidentifier: docidentifiers(node, ref, raw_id),
          title: titles(node, ref),
          date: dates(ref),
          contributor: contributors(node, ref),
          place: places(node),
          source: sources(node),
          note: notes(node),
        )
      end

      def docidentifiers(node, ref, raw_id)
        primary = primary_identifier(node, ref)
        stepmod_id = Bib::Docidentifier.new(content: raw_id,
                                            type: "STEPmod-id")
        primary ? [primary, stepmod_id] : [stepmod_id]
      end

      # A normref stdnumber is the bare number ("31-0"). A bibliography
      # stdnumber is already the full identifier ("ISO 286-1", "RFC 3986").
      def primary_identifier(node, ref)
        orgname = text(ref, "orgname")
        number = text(ref, "stdnumber")
        if number
          content = node.name == "normref" ? prefixed(orgname, number) : number
          type = docid_type(orgname)
        elsif (number = text(node, "number"))
          content = prefixed(text(node, "report-type"), number)
          type = "STEPmod"
        end
        return unless content

        Bib::Docidentifier.new(content: content, type: type, primary: true)
      end

      def prefixed(prefix, value)
        return value if prefix.nil? || value.start_with?(prefix)

        "#{prefix} #{value}"
      end

      def docid_type(orgname)
        case orgname
        when /\AISO/ then "ISO"
        when /\AIEC/ then "IEC"
        else "STEPmod"
        end
      end

      # A normref subtitle continues the title ("— Part 1: ..."). A
      # bibliography subtitle is free text, so it becomes a note instead.
      def titles(node, ref)
        main = strip_dashes(text(ref, "stdtitle"))
        return [] unless main

        subtitle = node.name == "normref" && strip_dashes(text(ref, "subtitle"))
        return [title_of(main, "main")] unless subtitle

        result = [title_of(join_title(main, subtitle), "main"),
                  title_of(main, "title-main")]
        part = subtitle.start_with?("Part")
        result << title_of(subtitle, "title-part") if part
        result
      end

      # Some subtitles continue the sentence (", corrected and reprinted
      # in 1995", "(OMG-UML VER 1.3)"); the others are title components.
      def join_title(main, subtitle)
        case subtitle
        when /\A[,;.]/ then "#{main}#{subtitle}"
        when /\A\(/ then "#{main} #{subtitle}"
        else "#{main} — #{subtitle}"
        end
      end

      def title_of(content, type)
        Bib::Title.new(content: content, type: type, language: "en",
                       script: "Latn")
      end

      def strip_dashes(value)
        stripped = value&.gsub(DASHES, "")
        stripped unless stripped.nil? || stripped.empty?
      end

      def notes(node)
        return [] if node.name == "normref"

        subtitle = text(node, "subtitle")
        subtitle ? [Bib::Note.new(content: subtitle)] : []
      end

      # STEPmod dates are "YYYY", "YYYY-MM-DD", or free text such as
      # "January 1992". Free text is kept as the date text. A value without
      # a year ("—", "-", "CHECK DATE") means "undated" and is dropped, and
      # so is a future date ("To be published in 2018").
      def dates(ref)
        value = text(ref, "pubdate")
        return [] unless value

        if value.match?(/\A\d{4}(-\d{2}){0,2}\z/)
          return [Bib::Date.new(type: "published", at: value)]
        end

        year = value[/\b(\d{4})\b/, 1]
        return [] if year.nil? || value.match?(/to be published/i)

        [Bib::Date.new(type: "published", at: year, text: value)]
      end

      def contributors(node, ref)
        authors = texts(node, "primary-responsibility").map do |name|
          Bib::Contributor.new(role: [role("author")], person: person(name))
        end
        publishers = %w[orgname institution publisher].flat_map do |tag|
          texts(tag == "orgname" ? ref : node, tag)
        end
        authors + publishers.uniq.map do |name|
          Bib::Contributor.new(role: [role("publisher")],
                               organization: organization(name))
        end
      end

      def role(type)
        Bib::Contributor::Role.new(type: type)
      end

      def person(name)
        Bib::Person.new(
          name: Bib::FullName.new(
            completename: Bib::LocalizedString.new(content: name),
          ),
        )
      end

      def organization(name)
        Bib::Organization.new(
          name: [Bib::TypedLocalizedString.new(content: name)],
        )
      end

      def places(node)
        texts(node, "place").map { |p| Bib::Place.new(formatted_place: p) }
      end

      def sources(node)
        texts(node, "ulink").map { |u| Bib::Uri.new(type: "src", content: u) }
      end

      def text(node, tag)
        texts(node, tag).first
      end

      def texts(node, tag)
        node.xpath("./#{tag}").filter_map do |el|
          value = el.text.gsub(/\s+/, " ").strip
          value unless value.empty?
        end
      end
    end
  end
end
