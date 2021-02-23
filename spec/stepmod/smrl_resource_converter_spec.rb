require 'spec_helper'

RSpec.describe Stepmod::Utils::SmrlResourceConverter do
  let(:input_xml) do
    <<~XML
      <resource>
        <schema name="contract_schema" number="8369" version="3">
          <introduction>
            The subject of the <b>contract_schema</b> is the description of contract agreements.
          </introduction>
          <fund_cons>
            Contract information may be attached to any aspect of a product data.
          </fund_cons>
          <express-g>
            <imgfile file="#{fixtures_path('basic_attribute_schemaexpg1.xml')}"/>
            <imgfile file="#{fixtures_path('basic_attribute_schemaexpg2.xml')}"/>
          </express-g>
        </schema>
      </resource>
    XML
  end

  let(:output) do
    <<~ADOC
      (*"contract_schema"
      == Introduction

      The subject of the *contract_schema* is the description of contract agreements.

      == Fundamental concerns

      Contract information may be attached to any aspect of a product data.

      [.svgmap]
      ====
      image::basic_attribute_schemaexpg1.svg[]

      * <<express:support_resource_schema>>; 1
      * <<express:basic_attribute_schema>>; 2
      ====

      [.svgmap]
      ====
      image::basic_attribute_schemaexpg2.svg[]

      * <<express:custom.name>>; 1
      * <<express:custom2.name2>>; 2
      ====
      *)
    ADOC
  end

  it 'Converts input file into the correct adoc' do
    expect(described_class.convert(input_xml)).to eq(output)
  end

  context 'when dl tags present' do
    let(:input_xml) do
      <<~XML
        <resource>
          <schema name="contract_schema" number="8369" version="3">
            <dl>
              <dt>one</dt>
              <dd>this is one</dd>
              <dt>two</dt>
              <dd>this is two</dd>
              <dt></dt><dd>a3ma &#160; : &#160; annotated 3d model assembly</dd>
              <dt>
              </dl> </dt>
              <dd>This is blank</dd>
          </schema>
        </resource>
      XML
    end
    let(:output) do
      "(*\"contract_schema\"\none:: this is one\n\ntwo:: this is two\n\na3ma:: annotated 3d model assembly\n\n{blank}:: This is blank\n*)\n"
    end

    it 'renders correclt internal dl tags and children' do
      expect(described_class.convert(input_xml)).to eq(output)
    end
  end

  context 'when table elements present' do
    let(:input_xml) do
      <<~XML
      <resource>
        <schema name="contract_schema" number="8369" version="3">
          // start of first table
          <table number="1" caption="Population of Internal_probe_access_area">
              <tr>
                <th colspan="2" align="left">#2000=<b>Internal_probe_access_area</b>(referenced as SELF in following lines)</th></tr> <!-- table header row -->
              <tr align="left">
                <td>SELF\<express_ref linkend="product_occurrence:arm:Product_occurrence_arm.Definition_based_product_occurrence.derived_from">Definition_based_product_occurrence.derived_from</express_ref></td>
                <td>#2222=<express_ref linkend="Layered_interconnect_simple_template:arm:Layered_interconnect_simple_template_arm.Stratum_feature_template"/>;</td></tr>
              <tr align="left">
                <td>SELF\<express_ref linkend="Layered_interconnect_module_design:arm:Layered_interconnect_module_design_arm.Probe_access_area.probed_layout_item">Probe_access_area.probed_layout_item</express_ref></td>
                <td>#2233=<express_ref linkend="Layered_interconnect_module_design:arm:Layered_interconnect_module_design_arm.Stratum_feature"/> (on layer 6 and part of implementation of net 3CB022)</td></tr>
          <!--
              <tr align="left">
                <td>SELF\<express_ref linkend="Feature_and_connection_zone:arm:Feature_and_connection_zone_arm.Definitional_shape_element.connection_area">Definitional_shape_element.connection_area</express_ref></td>
                <td>#3211=<express_ref linkend="Physical_unit_design_view:arm:Physical_unit_design_view_arm.Connection_zone_in_design_view"/>; (visible from external environment and geometrically a subset of #4444 geometry)</td></tr>
          -->
              <tr align="left">
                <td>SELF\<express_ref linkend="Layered_interconnect_module_design:arm:Layered_interconnect_module_design_arm.Probe_access_area.stratum_feature_material_stackup">Probe_access_area.stratum_feature_material_stackup</express_ref></td>
                <td>not provided;</td></tr>
              <tr align="left">
                <td><b>stratum_feature_implementation</b></td>
                <td>#4444=<express_ref linkend="Layered_interconnect_module_design:arm:Layered_interconnect_module_design_arm.Stratum_feature"/> composed only of one <express_ref linkend="Land:arm:Land_arm.Land"/> (on top layer). </td></tr>
                  <tr align="left">
                    <td><b>internal_access</b></td>
                    <td>#2000 is referenced by #3000 </td></tr>
              <!-- end of first table -->
              </table>
        </schema>
      </resource>
      XML
    end
    let(:output) do
      <<~ADOC
        (*"contract_schema"
        // start of first table

        |===
        2+<| #2000=*Internal_probe_access_area*(referenced as SELF in following lines)

        // table header row
        | SELF<<express:Product_occurrence_arm.Definition_based_product_occurrence.derived_from,derived_from>> | #2222=<<express:Layered_interconnect_simple_template_arm.Stratum_feature_template,Stratum_feature_template>>;
        | SELF<<express:Layered_interconnect_module_design_arm.Probe_access_area.probed_layout_item,probed_layout_item>> | #2233=<<express:Layered_interconnect_module_design_arm.Stratum_feature,Stratum_feature>> (on layer 6 and part of implementation of net 3CB022)
        // <tr align="left">
        // <td>SELF<express_ref linkend="Feature_and_connection_zone:arm:Feature_and_connection_zone_arm.Definitional_shape_element.connection_area">Definitional_shape_element.connection_area</express_ref></td>
        // <td>#3211=<express_ref linkend="Physical_unit_design_view:arm:Physical_unit_design_view_arm.Connection_zone_in_design_view"/>; (visible from external environment and geometrically a subset of #4444 geometry)</td></tr>
        | SELF<<express:Layered_interconnect_module_design_arm.Probe_access_area.stratum_feature_material_stackup,stratum_feature_material_stackup>> | not provided;
        | *stratum_feature_implementation* | #4444=<<express:Layered_interconnect_module_design_arm.Stratum_feature,Stratum_feature>> composed only of one <<express:Land_arm.Land,Land>> (on top layer).
        | *internal_access* | #2000 is referenced by #3000
        // end of first table

        |===
        *)
      ADOC
    end

    it 'Converts table elements into the correct adoc' do
      expect(described_class.convert(input_xml).gsub(/ \n/, "\n")).to eq(output)
    end
  end

  context 'when eqn tags' do
    let(:input_xml) do
      <<~XML
        <resource>
          <schema name="contract_schema" number="8369" version="3">
            A <b>Different_assembly_constraint_type</b> is a type of
            one or more assembly constraints between a component and its connected component in the comparing assembly
            data set
            have different type from that of the corresponding component and its connected component in the compared
            assembly data set.

            <p>
              The inspection requirement corresponding to this criterion is,
            </p>
            <ul>
              <li>
                for each pair of the comparing assembly data set that is an element of a target assembly data set
                and the compared assembly data set that is the corresponding element of the other target assembly data
                set,
              </li>
              <ul>
                <li>
                  <eqn id="eqnGM1">
                    <i>
                      &#967;
                      <sub>ms</sub>
                      =
                      <b>V - E + 2F - L</b>
                      <sub>l</sub>
                      <b> - 2(S - G</b>
                      <sup>s</sup>)
                    </i>
                    = 0 &#8195; (1) &#8195;
                  </eqn>
                  is different from the type of the corresponding assembly constraint in the compared assembly data set.
                </li>
              </ul>
            </ul>
          </schema>
        </resource>
      XML
    end
    let(:output) do
      <<~XML
        (*"contract_schema"
        A *Different_assembly_constraint_type* is a type of one or more assembly constraints between a component and its connected component in the comparing assembly data set have different type from that of the corresponding component and its connected component in the compared assembly data set.

        The inspection requirement corresponding to this criterion is,

        * for each pair of the comparing assembly data set that is an element of a target assembly data set and the compared assembly data set that is the corresponding element of the other target assembly data set,

        ** [[eqnGM1]]

        [stem]
        ++++
        χ ms = V - E + 2F - L l - 2(S - G s) = 0
        ++++

        is different from the type of the corresponding assembly constraint in the compared assembly data set.
        *)
      XML
    end

    it 'correctly renders nested lists' do
      input = node_for(input_xml)
      expect(described_class.convert(input).gsub(/ \n/, "\n")).to eq(output)
    end
  end
end
