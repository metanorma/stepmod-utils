require "spec_helper"
require "support/smrl_converters_setup"
require "expressir"
require "expressir/express/parser"

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
    let(:entity_definition) { nil }
    let(:input_xml) do
      <<~XML
        <ext_description linkend="action_schema.supported_item">
          Old Definition
        </ext_description>
      XML
    end

    let(:output) do
      <<~OUTPUT
        // STEPmod path:
        === supported_item
        domain:[resource: action_schema]

        Old Definition


        [.source]
        <<ISO_10303-41_2020>>

      OUTPUT
    end

    it "correctly renders nil because entity in exp file does not exist" do
      expect(parse.to_mn_adoc).to eq(output)
    end
  end

  context "when action" do
    let(:entity_definition) { "domain:[resource: action_schema]\n\nentity data type that represents an action entity" }

    let(:input_xml) do
      <<~XML
        <ext_description linkend="action_schema.action">
          An <b>action</b> is the identification of the occurrence of an activity and a description of its result.
          <p>
          An <b>action</b> identifies an activity that has taken place, is taking place, or is expected to take place in the future.
          </p>
          <p>
          An action has a definition that is specified by an
          <express_ref linkend="action_schema:ir_express:action_schema.action_method"/>.
          </p>
          <note number="1">
            In particular application domains, terms such as task, process, activity, operation, and event may be synonyms for <b>action</b>.
          </note>
          <example>
            Change, distilling, design, a process to drill a hole, and a task such as training someone are examples of actions.
          </example>
        </ext_description>
      XML
    end

    let(:output) do
      <<~OUTPUT
        // STEPmod path:
        === action
        domain:[resource: action_schema]

        An *action* is the identification of the occurrence of an activity and a description of its result.


        [.source]
        <<ISO_10303-41_2020>>

      OUTPUT
    end

    it "correctly renders definition" do
      expect(parse.to_mn_adoc).to eq(output)
    end
  end

  context "when ext_description contains list" do
    let(:entity_definition) { "domain:[resource: set_theory_schema]\n\nentity data type that represents a complement entity" }

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
        domain:[resource: set_theory_schema]

        A *complement* is a relationship that is between

        * set S1,
        * set U, and
        * set S2,

        that indicates set S2 consists of all members of U that are not members of S1.


        [.source]
        <<ISO_10303-41_2020>>

      OUTPUT
    end

    it "correctly renders definition" do
      expect(parse.to_mn_adoc).to eq(output)
    end
  end

  context "when definition xml" do
    let(:entity_definition) { nil }
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
