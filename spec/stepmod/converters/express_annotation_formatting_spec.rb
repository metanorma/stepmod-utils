# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"
require "stepmod/utils/converters/express_note"
require "stepmod/utils/converters/express_example"
require "stepmod/utils/converters/express_figure"

# https://github.com/metanorma/stepmod-utils/issues/262
RSpec.describe "annotated EXPRESS content formatting" do
  let(:linkend) { "geometry_schema.axis2_placement_3d.p" }
  let(:state) { { schema_and_entity: linkend, figure_ids: ["Geomfig3"] } }

  def convert_with(converter, xml, state)
    converter.new.convert(node_for(xml), state)
  end

  def note(body)
    convert_with(Stepmod::Utils::Converters::ExpressNote,
                 "<note>#{body}</note>", state)
  end

  def example(body)
    convert_with(Stepmod::Utils::Converters::ExpressExample,
                 "<example>#{body}</example>", state)
  end

  def description(body)
    Stepmod::Utils::SmrlDescriptionConverter.convert(
      "<ext_descriptions><ext_description linkend='#{linkend}'>" \
      "<p>#{body}</p></ext_description></ext_descriptions>",
    )
  end

  describe "partial bold inside a word" do
    let(:body) { "The un<b>bold</b>ed word" }

    it "uses unconstrained bold in notes" do
      expect(note(body)).to include("The un**bold**ed word")
    end

    it "uses unconstrained bold in examples" do
      expect(example(body)).to include("The un**bold**ed word")
    end

    it "does not split the word in descriptions" do
      expect(description(body)).to include("The un**bold**ed word")
    end

    it "keeps constrained bold for a whole word" do
      expect(note("a <b>bold</b> word")).to include("a *bold* word")
    end
  end

  describe "italic and bold together" do
    it "writes italic-bold as bold outside in notes" do
      expect(note("where <i><b>V</b></i> and <i><b>E</b></i> are"))
        .to include("where *_V_* and *_E_* are")
    end

    it "keeps bold-italic as it was" do
      expect(note("<b><i>E</i></b> end")).to include("*_E_* end")
    end

    it "does not pad the markup in descriptions" do
      expect(description("where <i><b>V</b></i> is"))
        .to include("where **_V_** is")
    end

    it "keeps plain italic" do
      expect(note("an <i>italic</i> word")).to include("an _italic_ word")
    end
  end

  describe "figure references" do
    let(:anchor) { "figure-geometry_schema-Geomfig3" }
    let(:figure) do
      convert_with(
        Stepmod::Utils::Converters::ExpressFigure,
        "<figure id='Geomfig3'><title>Axis</title>" \
        "<img src='Geomfig3.gif'/></figure>",
        state,
      )
    end

    it "anchors the figure with the shared id" do
      expect(figure).to include("[[#{anchor}]]")
    end

    it "points a figure_ prefixed reference at the anchor" do
      expect(note("See <a href='#figure_Geomfig3'>Figure 1</a>"))
        .to include("<<#{anchor}>>")
    end

    it "points a reference by bare figure id at the anchor" do
      expect(note("See <a href='#Geomfig3'>Figure 1</a>"))
        .to include("<<#{anchor}>>")
    end

    it "leaves references to non-figures alone" do
      expect(note("See <a href='#other'>Figure 1</a>")).to include("<<other>>")
    end
  end
end
