# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"
require "stepmod/utils/converters/eqn"

RSpec.describe Stepmod::Utils::Converters::Eqn do
  subject(:convert) do
    cleaned_adoc(described_class.new.convert(node_for(input_xml)))
  end

  let(:input_xml) do
    <<~XML
      <eqn id="eqnGM1">
        <i>
          &#x3C7;
          <b>My node</b>
          <sub>ms</sub>
          <i>Italic text</i>
          =
          <b><i>V - E + 2F - L</i></b>
          <sub>l</sub>
          <b> - 2(S - G</b>
          <sup>s</sup>)
        </i>
        = 0 &#x2003; (1) &#x2003;
      </eqn>
    XML
  end
  let(:output) do
    <<~XML
      [[eqnGM1]]

      [stem]
      ++++
      ii(χ bb(My node)_{ms}ii(Italic text) = bb(ii(V - E + 2F - L))_{l}bb(- 2(S - G)^{s})) = 0
      ++++

    XML
  end

  it "converts complex children block by rules" do
    expect(convert).to eq(output)
  end

  context "with bold and italics" do
    let(:input_xml) do
      <<~EQUATION
        <eqn>
          <b> &#955;</b><i>(u)</i> =
          <b>C</b> +
          R(cos(<i>u</i>)<b>x</b> +
          sin(<i>u</i>)<b>y</b>)
        </eqn>
      EQUATION
    end

    let(:expected_output) do
      <<~OUTPUT

        [stem]
        ++++
        bb(λ)ii((u)) = bb(C) + R(cos(ii(u))bb(x) + sin(ii(u))bb(y))
        ++++

      OUTPUT
    end

    it "should add bb() and ii() for bold and italics respectively" do
      expect(convert).to eq(expected_output)
    end
  end

  context "when special symbols are used" do
    let(:input_xml) do
      <<~XML
        <eqn id="eqnGM1"> <i> &#967; <sub>ms</sub> = <b>V - E + 2F - L</b> <sub>l</sub> <b> - 2(S - G</b> <sup>s</sup>) </i> = 0 &#8195; (1) &#8195; </eqn>
      XML
    end
    let(:output) do
      <<~XML
        [[eqnGM1]]

        [stem]
        ++++
        ii(χ_{ms} = bb(V - E + 2F - L)_{l} bb(- 2(S - G) ^{s})) = 0
        ++++

      XML
    end

    it "converts special symbols in element" do
      expect(convert).to eq(output)
    end
  end

  context "when eqn is actually a definition list" do
    let(:input_xml) do
      <<~XML
        <eqn> <b>directrix</b> : a circle in 3D space of radius R <sub>1</sub> , </eqn>
      XML
    end
    let(:output) do
      <<~XML


        directrix:: a circle in 3D space of radius R_{1} ,
      XML
    end

    it "converts special symbols in element" do
      expect(convert).to eq(output)
    end
  end

  context "when underscore variable is used" do
    let(:input_xml) do
      <<~XML
        <eqn> <i> K1 </i> = <b>upper_index_on_u_control_points</b> </eqn>
      XML
    end
    let(:output) do
      <<~XML

        [stem]
        ++++
        ii(K1) = bb("upper_index_on_u_control_points")
        ++++

      XML
    end

    it "converts special symbols in element" do
      expect(convert).to eq(output)
    end
  end

  context "when sup/sub tags used" do
    let(:input_xml) do
      <<~XML
        <eqn> <b>s</b>(u,v) = (1 - u -v)<sup>3</sup><b>P<sub>1</sub></b> + u<sup>3</sup><b>P<sub>2</sub></b> + v<sup>3</sup><b>P<sub>3</sub></b> + 3(1 - u -v)<sup>2</sup>u<b>P<sub>4</sub></b> + 3(1 - u -v)u<sup>2</sup><b>P<sub>5</sub></b> + 3u<sup>2</sup>v<b>P<sub>6</sub></b> + 3uv<sup>2</sup><b>P<sub>7</sub></b> + 3(1 - u -v)v<sup>2</sup><b>P<sub>8</sub></b> + 3(1 - u -v)<sup>2</sup>v<b>P<sub>9</sub></b> + 6uv(1 - u -v)<b>P<sub>10</sub></b> </eqn>
      XML
    end
    let(:output) do
      <<~XML

        [stem]
        ++++
        bb(s)(u,v) = (1 - u -v)^{3}bb(P_{1}) + u^{3}bb(P_{2}) + v^{3}bb(P_{3}) + 3(1 - u -v)^{2}ubb(P_{4}) + 3(1 - u -v)u^{2}bb(P_{5}) + 3u^{2}vbb(P_{6}) + 3uv^{2}bb(P_{7}) + 3(1 - u -v)v^{2}bb(P_{8}) + 3(1 - u -v)^{2}vbb(P_{9}) + 6uv(1 - u -v)bb(P_{10})
        ++++

      XML
    end
    it "converts complex children block by rules" do
      expect(convert).to eq(output)
    end
  end
end
