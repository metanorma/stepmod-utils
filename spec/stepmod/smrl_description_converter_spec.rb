require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::SmrlDescriptionConverter do
  let(:schema) { "schema" }

  it "takes ext_description linkend attribute" do
    input = node_for(
      <<~XML,
        <ext_descriptions>
          <ext_description linkend='#{schema}'></ext_description>
        </ext_descriptions>
      XML
    )
    expect(described_class.convert(input)).to include(%{(*"#{schema}"})
  end

  it "converts html children" do
    input = node_for(
      <<~XML,
        <ext_descriptions>
          <ext_description linkend='#{schema}'><li>foo</li></ext_description>
        </ext_descriptions>
      XML
    )
    expect(described_class.convert(input)).to include("foo\n")
  end

  it "converts express_ref tags into the new format" do
    input = node_for(
      <<~XML,
        <express_ref linkend="classification_and_set_theory:ir:classification_schema.class" />
      XML
    )
    expect(described_class.convert(input))
      .to(eq("<<express:classification_schema.class,class>>"))
  end

  context "when nested lists" do
    let(:input_xml) do
      <<~XML
        <ext_description linkend="Annotated_3d_model_equivalence_assembly_arm.Different_assembly_constraint_type">
          A <b>Different_assembly_constraint_type</b> is a type of
          <express_ref
            linkend="annotated_3d_model_equivalence_assembly:arm:Annotated_3d_model_equivalence_assembly_arm.A3m_equivalence_criterion_of_detailed_assembly_data_content" />
          that asserts that
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
                to check if the type of assembly constraint between components in the comparing assembly data set
                is different from the type of the corresponding assembly constraint in the compared assembly data set.
              </li>
            </ul>
          </ul>
          Inspection shall be made in both ways; the comparing against the compared assembly data sets, and the compared
          against the comparing assembly data sets.
          <note>
            This criterion only checks the types of connecting relationship.
            Use the criterion
            <express_ref
              linkend="annotated_3d_model_equivalence_assembly:arm:Annotated_3d_model_equivalence_assembly_arm.Different_angle_of_assembly_constraint" />
            or
            <express_ref
              linkend="annotated_3d_model_equivalence_assembly:arm:Annotated_3d_model_equivalence_assembly_arm.Different_length_of_assembly_constraint" />
            to check the difference of the dimensions specified in the constraint.
          </note>
          A <express_ref linkend="analysis_schema:ir_express:analysis_schema.numerical_model"/> is an aspect of a physical object relevant to a particular type of behavoir. A <express_ref linkend="analysis_schema:ir_express:analysis_schema.numerical_model"/> takes a particular view of its domain in terms of dimensionality and continuity.
          <example number="1"> Examples include: 3D continuum (volume elements in FEA); 2D continuum (shell elements in FEA); 1D continuum (beam elements in FEA); lumped masses (in a many-body problem).
          </example>
          A <express_ref linkend="analysis_schema:ir_express:analysis_schema.numerical_model"/> is a view of a <b>temporal_spatial_object</b> specificiation as a set or space. The members of the set or space may consist of:
          <ul><li>points in space-time;</li>
          <li>spatial or temporal aggregations that are finite in one or more dimensions.</li>
          </ul>
          <note number="1"> Only an object that is a set or space can be the domain of a distribution function.</note>
        </ext_description>
      XML
    end
    let(:output) do
      <<~XML
        (*"Annotated_3d_model_equivalence_assembly_arm.Different_assembly_constraint_type"
        A *Different_assembly_constraint_type* is a type of <<express:Annotated_3d_model_equivalence_assembly_arm.A3m_equivalence_criterion_of_detailed_assembly_data_content,A3m_equivalence_criterion_of_detailed_assembly_data_content>> that asserts that one or more assembly constraints between a component and its connected component in the comparing assembly data set have different type from that of the corresponding component and its connected component in the compared assembly data set.

        The inspection requirement corresponding to this criterion is,

        * for each pair of the comparing assembly data set that is an element of a target assembly data set and the compared assembly data set that is the corresponding element of the other target assembly data set,

        ** to check if the type of assembly constraint between components in the comparing assembly data set is different from the type of the corresponding assembly constraint in the compared assembly data set.

        Inspection shall be made in both ways; the comparing against the compared assembly data sets, and the compared against the comparing assembly data sets.
        [NOTE]
        --
        This criterion only checks the types of connecting relationship. Use the criterion <<express:Annotated_3d_model_equivalence_assembly_arm.Different_angle_of_assembly_constraint,Different_angle_of_assembly_constraint>> or <<express:Annotated_3d_model_equivalence_assembly_arm.Different_length_of_assembly_constraint,Different_length_of_assembly_constraint>> to check the difference of the dimensions specified in the constraint.
        --

        A <<express:analysis_schema.numerical_model,numerical_model>> is an aspect of a physical object relevant to a particular type of behavoir. A <<express:analysis_schema.numerical_model,numerical_model>> takes a particular view of its domain in terms of dimensionality and continuity.
        [example]
        ====
        Examples include: 3D continuum (volume elements in FEA); 2D continuum (shell elements in FEA); 1D continuum (beam elements in FEA); lumped masses (in a many-body problem).
        ====

        A <<express:analysis_schema.numerical_model,numerical_model>> is a view of a *temporal_spatial_object* specificiation as a set or space. The members of the set or space may consist of:

        * points in space-time;
        * spatial or temporal aggregations that are finite in one or more dimensions.

        [NOTE]
        --
        Only an object that is a set or space can be the domain of a distribution function.
        --
        *)
      XML
    end

    it "correctly renders nested lists" do
      input = node_for(input_xml)
      expect(described_class.convert(input).gsub(/ \n/, "\n")).to eq(output)
    end
  end
end
