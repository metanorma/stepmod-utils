require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Concept do
  subject(:parse) do
    described_class
      .parse(
        input,
        reference_anchor: "ISO_10303-41_2020",
        reference_clause: nil,
        file_path: "",
      )
  end

  let(:input) { node_for(input_xml) }

  original_ext_description = ReverseAdoc::Converters.lookup(:ext_description)
  original_express_ref = ReverseAdoc::Converters.lookup(:express_ref)
  before do
    require "stepmod/utils/converters/stepmod_ext_description"
    ReverseAdoc::Converters.register :ext_description,
                                     Stepmod::Utils::Converters::StepmodExtDescription.new
    ReverseAdoc::Converters.register :express_ref,
                                     Stepmod::Utils::Converters::ExpressRef.new
  end

  context "when action_schema" do
    let(:input_xml) do
      <<~XML
        <ext_description linkend="action_schema.supported_item">
          The <b>supported_item</b> allows for the designation of an
          <express_ref linkend="action_schema:ir_express:action_schema.action_directive"/>,
          an
          <express_ref linkend="action_schema:ir_express:action_schema.action"/>,
          or an
          <express_ref linkend="action_schema:ir_express:action_schema.action_method"/>.
          <note>
            This specifies the use of an
            <express_ref linkend="action_schema:ir_express:action_schema.action_resource"/>.
          </note>
        </ext_description>
      XML
    end

    let(:output) do
      <<~OUTPUT
        // STEPmod path:
        === supported_item

        domain:[ISO 10303 resource]

        The *supported_item* allows for the designation of an *action_directive*, an *action*, or an *action_method*.


        NOTE: This term is incompletely defined in this document.
        Reference <<ISO_10303-41_2020>> for the complete definition.


        [.source]
        <<ISO_10303-41_2020>>

      OUTPUT
    end

    it "correctly renders definition" do
      expect(parse.to_mn_adoc).to eq(output)
    end
  end

  context "when ext_description contains list" do
    let(:input_xml) do
      <<~XML
        <ext_description linkend="set_theory_schema.complement"><p>A <b>complement</b> is a relationship that is between</p>
        <ul><li>
        set S1,</li><li>
        set U, and</li><li>
        set S2,</li></ul>
        <p>that indicates set S2 consists of all members of U that are not members of S1.
        </p></ext_description>
      XML
    end

    let(:output) do
      <<~OUTPUT
        // STEPmod path:
        === complement

        domain:[ISO 10303 resource]

        A *complement* is a relationship that is between

        * set S1,
        * set U, and
        * set S2,

        that indicates set S2 consists of all members of U that are not members of S1.


        NOTE: This term is incompletely defined in this document.
        Reference <<ISO_10303-41_2020>> for the complete definition.


        [.source]
        <<ISO_10303-41_2020>>

      OUTPUT
    end

    it "correctly renders definition" do
      expect(parse.to_mn_adoc).to eq(output)
    end


  end


  context "when definition xml" do
    let(:input_xml) do
      <<~XML
        <definition>
          <term>boundary representation solid model</term>
          <def>
            <p> B-rep </p>
            <p> Test </p>
            type of geometric model in which the size and shape of a solid is
            defined in terms of the faces, edges
            and vertices which make up its boundary
          </def>
        </definition>
      XML
    end

    let(:output) do
      <<~OUTPUT
        // STEPmod path:
        === boundary representation solid model

        alt:[B-rep,Test]

        type of geometric model in which the size and shape of a solid is defined in terms of the faces, edges and vertices which make up its boundary

        [.source]
        <<ISO_10303-41_2020>>

      OUTPUT
    end

    let(:designation) do
      {
        accepted: "boundary representation solid model",
        alt: [" B-rep ", " Test "],
      }
    end

    it "correctly parses and stores designation" do
      expect(parse.designations).to(eq([designation]))
    end

    it "correctly renders ascidoc output" do
      expect(parse.to_mn_adoc).to(eq(output))
    end
  end

  after do
    ReverseAdoc::Converters.register :ext_description, original_ext_description
    ReverseAdoc::Converters.register :express_ref, original_express_ref
  end
end
