# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::Table do
  let(:converter) { described_class.new }

  let(:xml_input) do
    <<~XML
      <table caption="Geometry mathematical symbology" number="1" id="table_1">
        <tr>
          <th>Symbol</th>
          <th>Definition</th>
        </tr>
        <tr>
          <td><i>a</i></td>
          <td>Scalar quantity </td>
        </tr>
        <tr>
          <td><b>A</b></td>
          <td>Vector quantity</td>
        </tr>
        <tr>
          <td>&lt; &gt; </td>
          <td>Vector normalisation </td>
        </tr>
        <tr>
          <td><b>a</b></td>
          <td>Normalised vector &lt; <b>A</b> &gt; = <b>A</b> / | <b>A</b> |</td>
        </tr>
        <tr>
          <td> × </td>
          <td>Vector (cross) product </td>
        </tr>
        <tr>
          <td>⋅ </td>
          <td>Scalar product </td>
        </tr>
        <tr>
          <td><b>A</b> → <b>B</b></td>
          <td><b>A</b> is transformed to <b>B</b></td>
        </tr>
        <tr>
          <td>λ<i>(u)</i></td>
          <td>Parametric curve </td>
        </tr>
        <tr>
          <td>σ<i>(u,v)</i></td>
          <td>Parametric surface </td>
        </tr>
        <tr>
          <td><i>S(x,y,z)</i></td>
          <td>Analytic surface </td>
        </tr>
        <tr>
          <td><i>C<sub>x</sub></i></td>
          <td>Partial differential of <i>C</i> with respect to <i>x</i></td>
        </tr>
        <tr>
          <td>σ<sub><i>u</i></sub></td>
          <td>Partial differential of σ <i>(u,v)</i> with respect to <i>u</i></td>
        </tr>
        <tr>
          <td><i>S<sub>x</sub></i></td>
          <td>Partial derivative of <i>S</i> with respect to <i>x</i></td>
        </tr>
        <tr>
          <td>| |</td>
          <td>Absolute value, or magnitude or determinant </td>
        </tr>
        <tr>
          <td>R<sup>m</sup></td>
          <td>m-dimensional real space</td>
        </tr>
      </table>
    XML
  end

  let(:output) do
    <<~OUTPUT
      [[table-table-geometry_schema-table_1]]
      .Geometry mathematical symbology
      |===
      | Symbol | Definition

      | _a_ | Scalar quantity
      | *A* | Vector quantity
      | < >  | Vector normalisation
      | *a* | Normalised vector < *A* > = *A* / \\| *A* \\|
      |  ×  | Vector (cross) product
      | ⋅  | Scalar product
      | *A* → *B* | *A* is transformed to *B*
      | λ_(u)_ | Parametric curve
      | σ_(u,v)_ | Parametric surface
      | _S(x,y,z)_ | Analytic surface
      | _C~x~_ | Partial differential of _C_ with respect to _x_
      | σ~_u_~ | Partial differential of σ _(u,v)_ with respect to _u_
      | _S~x~_ | Partial derivative of _S_ with respect to _x_
      | \\| \\| | Absolute value, or magnitude or determinant
      | R^m^ | m-dimensional real space

      |===
    OUTPUT
  end

  let(:state) { { schema_and_entity: "geometry_schema" } }

  it "converts table and escapes characters correctly" do
    input = node_for(xml_input)
    expect(converter.convert(input, state).strip).to eq(output.strip)
  end
end
