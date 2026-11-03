require "spec_helper"
require "open3"
require "tmpdir"
require "stepmod/utils/bibliography_converter"

RSpec.describe Stepmod::Utils::BibliographyConverter do
  let(:normrefs) { fixtures_path("bibliography/normrefs.xml") }
  let(:bibliography) { fixtures_path("bibliography/bibliography.xml") }
  let(:converter) do
    described_class.new(normrefs: normrefs, bibliography: bibliography)
  end
  let(:items) { converter.items }

  def item(id)
    items.find { |i| i.id == id } or raise "no item #{id}"
  end

  def docid(item, type)
    item.docidentifier.find { |d| d.type == type }&.content
  end

  def title(item, type)
    item.title.find { |t| t.type == type }&.content
  end

  def contributors(item, role)
    item.contributor.select { |c| c.role.map(&:type).include?(role) }
  end

  describe "#items" do
    it "converts every entry once, skipping a duplicate id" do
      expect(items.size).to eq(6 + 10)
      expect(items.map(&:id).uniq.size).to eq(items.size)
    end

    it "warns about a duplicate id" do
      expect { converter.items }
        .to output(/duplicate id "ref17450-1"/).to_stderr
    end

    it "warns about an id that collides after sanitizing" do
      expect { converter.items }
        .to output(/duplicate id "ISO_31-all"/).to_stderr
      expect(docid(item("bibitem_ISO_31-all"), "STEPmod-id"))
        .to eq("ISO 31-all")
    end

    it "warns about an unknown entity" do
      expect { converter.items }
        .to output(/unknown entity &unknownentity;/).to_stderr
    end

    it "prefixes ids by the source list, like the migrated documents" do
      expect(items.map(&:id)).to include(
        "normref_ref31-0", "bibitem_ref8824-1", "bibitem_BLANCHARD1998"
      )
    end

    it "sanitizes ids that are not XML names" do
      expect(item("bibitem_ISO_31-all")).not_to be_nil
    end

    it "keeps the raw STEPmod id as a docidentifier" do
      expect(docid(item("bibitem_ISO_31-all"),
                   "STEPmod-id")).to eq("ISO 31-all")
    end

    context "with a normref" do
      subject(:ref) { item("normref_ref31-0") }

      it "builds the primary identifier from orgname and stdnumber" do
        primary = ref.docidentifier.find(&:primary)
        expect([primary.type, primary.content]).to eq(["ISO", "ISO 31-0"])
      end

      it "joins the title parts with an em dash" do
        expect(title(ref, "main"))
          .to eq("Quantities and units — Part 0: General principles")
        expect(title(ref, "title-main")).to eq("Quantities and units")
        expect(title(ref, "title-part")).to eq("Part 0: General principles")
      end

      it "sets the type, the published date and the publisher" do
        expect(ref.type).to eq("standard")
        expect(ref.date.first.type).to eq("published")
        expect(ref.date.first.at.to_s).to eq("1992")
        expect(contributors(ref, "publisher").first.organization.name
          .first.content).to eq("ISO")
      end

      it "drops a title-part for a subtitle that is not a part" do
        ref = item("normref_ref2553-2013")
        expect(title(ref, "main")).to eq(
          "Welding and allied processes — Symbolic representation on " \
          "drawings — Welded joints",
        )
        expect(title(ref, "title-part")).to be_nil
      end

      it "ignores a pubdate without a year" do
        expect(item("normref_ref2553-2013").date).to be_empty
      end

      it "strips dangling dashes between the title and the subtitle" do
        expect(title(item("normref_ref17450-1"), "main")).to eq(
          "Geometrical Product Specifications (GPS) — Geometrical concepts " \
          "— Part 1: Model for geometrical specification and verification",
        )
      end

      it "appends a subtitle that continues the title without a dash" do
        ref = item("normref_uncertainty")
        expect(title(ref, "main")).to eq(
          "Guide to the expression of uncertainty in measurement (GUM), " \
          "corrected and reprinted in 1995",
        )
        expect(ref.docidentifier.map(&:type)).to eq(["STEPmod-id"])
      end

      it "uses the IEC docidentifier type for IEC" do
        expect(docid(item("normref_refIEC80000"), "IEC"))
          .to eq("IEC 80000(all parts)")
      end

      it "does not convert <term> children" do
        xml = converter.to_xml
        expect(xml).not_to include("reference feature")
      end
    end

    context "with a bibitem" do
      it "does not repeat the orgname already in stdnumber" do
        expect(docid(item("bibitem_ref8824-1"), "ISO")).to eq("ISO/IEC 8824-1")
      end

      it "resolves the HTML entities" do
        expect(title(item("bibitem_ref8824-1"), "main")).to eq(
          "Information technology — Abstract Syntax Notation One (ASN.1) — " \
          "Part 1: Specification of basic notation",
        )
      end

      it "uses the STEPmod docidentifier type for another organization" do
        ref = item("bibitem_aws-a2.4-2012")
        primary = ref.docidentifier.find(&:primary)
        expect([primary.type, primary.content])
          .to eq(["STEPmod", "AWS-A2.4 2012"])
      end

      it "keeps the subtitle as a note" do
        expect(item("bibitem_ref286_1.").note.map(&:content))
          .to eq(["new ed. to be published imminently"])
      end

      it "maps ulink to a source" do
        src = item("bibitem_ietf3986.-").source.first
        expect([src.type, src.content])
          .to eq(["src", "http://www.ietf.org/rfc/rfc3986.txt"])
      end

      it "drops a date that is not published yet" do
        expect(item("bibitem_aws-a2.4-2012").date).to be_empty
      end

      it "keeps a free-text pubdate as the date text" do
        date = item("bibitem_IGES-5").date.first
        expect([date.at.to_s, date.text]).to eq(["1992", "January 1992"])
      end
    end

    context "with a techreport" do
      it "uses the number as the identifier" do
        ref = item("bibitem_AMConGde06")
        expect(ref.type).to eq("techreport")
        expect(ref.docidentifier.find(&:primary).content)
          .to eq("ISO TC 184/SC 4 N1685")
        expect(ref.date.first.at.to_s).to eq("2004-02-27")
      end

      it "prefixes the number with the report type" do
        ref = item("bibitem_NISTIR-7634")
        expect(ref.docidentifier.find(&:primary).content).to eq("NISTIR 7634")
        expect(contributors(ref, "publisher").first.organization.name
          .first.content)
          .to eq("National Institute of Standards and Technology")
        expect(contributors(ref, "author").first.person.name.completename
          .content).to eq("BRADY, K. G., STORI, J., and THURMAN, T.")
      end

      it "has no primary identifier without a number" do
        ref = item("bibitem_hamilton-mh-welding-symbol-elements")
        expect(ref.docidentifier.map(&:type)).to eq(["STEPmod-id"])
        expect(title(ref, "main")).to eq("Elements of a welding symbol")
      end
    end

    context "with a book" do
      subject(:ref) { item("bibitem_BLANCHARD1998") }

      it "maps the author, the publisher and the place" do
        expect(ref.type).to eq("book")
        expect(contributors(ref, "author").first.person.name.completename
          .content).to eq("BLANCHARD, Benjamin S. and FABRYCKY, Wolter J.")
        expect(contributors(ref, "publisher").first.organization.name
          .first.content).to eq("Prentice Hall")
        expect(ref.place.first.formatted_place).to eq("New Jersey")
      end
    end
  end

  describe "#to_xml" do
    let(:doc) { Nokogiri::XML(converter.to_xml) }
    let(:ns) { { "r" => "https://open.ribose.com/relaton-xml" } }

    it "writes a relaton-collection with one partOf relation per item" do
      expect(doc.root.name).to eq("relaton-collection")
      expect(doc.xpath("/r:relaton-collection/r:relation[@type='partOf']", ns)
        .size).to eq(items.size)
    end

    it "writes the collection title and author" do
      expect(doc.at_xpath("/r:relaton-collection/r:title", ns).text)
        .to eq("STEPmod bibliography")
      expect(doc.at_xpath("//r:contributor[r:role/@type='author']" \
                          "/r:organization/r:name", ns).text)
        .to eq("ISO/TC 184/SC 4")
    end

    it "writes items that Relaton can read back with their ids" do
      bibitems = doc.xpath("//r:relation/r:bibitem", ns)
      expect(bibitems.size).to eq(items.size)
      bibitems.each do |node|
        parsed = Relaton::Bib::Item.from_xml(node.to_xml)
        expect(parsed.id).to eq(node["id"])
        expect(parsed.title).not_to be_empty
      end
    end
  end

  it "accepts only one of the two lists" do
    only = described_class.new(normrefs: normrefs)
    expect(only.items.map(&:id)).to all(start_with("normref_"))
  end

  describe "exe/stepmod-convert-bibliography" do
    let(:exe) { File.join(Stepmod::Utils.root, "exe/stepmod-convert-bibliography") }

    it "writes the collection to the output file" do
      Dir.mktmpdir do |dir|
        out = File.join(dir, "collection.xml")
        _o, err, status = Open3.capture3(
          "ruby", exe, "--normrefs", normrefs, "--bibliography", bibliography,
          "-o", out
        )
        expect(status).to be_success, err
        xml = Nokogiri::XML(File.read(out))
        expect(xml.root.name).to eq("relaton-collection")
        expect(xml.root.element_children.count { |e| e.name == "relation" })
          .to eq(16)
      end
    end

    it "finds both files in a STEPmod directory" do
      Dir.mktmpdir do |dir|
        basic = File.join(dir, "data/basic")
        FileUtils.mkdir_p(basic)
        FileUtils.cp(normrefs, basic)
        FileUtils.cp(bibliography, basic)
        out = File.join(dir, "collection.xml")
        _o, err, status = Open3.capture3("ruby", exe, "-s", dir, "-o", out)
        expect(status).to be_success, err
        expect(File.read(out, encoding: "UTF-8").scan("<relation ").size)
          .to eq(16)
      end
    end

    it "fails with a usage message on an invalid option" do
      _o, err, status = Open3.capture3("ruby", exe, "--bogus")
      expect(status.exitstatus).to eq(1)
      expect(err).to include("invalid option: --bogus")
      expect(err).not_to include("OptionParser::InvalidOption")
    end

    it "fails without an input" do
      _o, err, status = Open3.capture3("ruby", exe, "-o", "x.xml")
      expect(status).not_to be_success
      expect(err).to include("--normrefs")
    end
  end
end
