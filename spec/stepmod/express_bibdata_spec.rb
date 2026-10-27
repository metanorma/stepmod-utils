require "spec_helper"
require "stepmod/utils/express_bibdata"
require "expressir"
require "expressir/express/parser"

RSpec.describe Stepmod::Utils::ExpressBibdata do
  subject(:bibdata) { described_class.new(schema: schema) }

  let(:schema_path) do
    fixtures_path(
      "stepmod_terms_mock_directory/data/modules/activity/arm_annotated.exp",
    )
  end
  let(:schema) { Expressir::Express::Parser.from_file(schema_path).schemas.first }

  it "reads the part, edition number and year from the pubid" do
    expect([bibdata.part, bibdata.version, bibdata.pub_year])
      .to eq([1047, 3, 2014])
  end

  it "keeps the doctype and the document identifier" do
    expect([bibdata.doctype, bibdata.docid])
      .to eq(["TS", "ISO/TS 10303-1047:2014"])
  end
end
