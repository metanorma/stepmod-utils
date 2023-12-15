require 'spec_helper'
require 'support/smrl_converters_setup'

RSpec.describe Stepmod::Utils::StepmodDefinitionConverter do
  subject(:convert) { cleaned_adoc(described_class.convert(input_xml)) }

  context 'bold whitespace' do
    let(:input_xml) do
      <<~XML
      <ext_description linkend="aic_machining_feature.profile_floor">
        A <b>profile_floor</b> is a type of
        <express_ref linkend="product_property_definition_schema:ir_express:product_property_definition_schema.shape_aspect"/>
        that is the representation of the bottom condition for an
        <express_ref linkend="aic_machining_feature:ir_express:aic_machining_feature.outside_profile"/>
        <express_ref linkend="shape_aspect_definition_schema:ir_express:shape_aspect_definition_schema.feature_definition"/>.
        <note>
          A
          <express_ref linkend="Machining_features:arm:Machining_features_arm.Profile_floor"/>,
          <express_ref linkend="Machining_features:arm:Machining_features_arm.General_profile_floor"/>
          or a
          <express_ref linkend="Machining_features:arm:Machining_features_arm.Planar_profile_floor"/>
          are defined in ISO 10303-1814 [5] and define the requirement for <b>profile_floor</b>.
        </note>
      </ext_description>
      XML
    end
    let(:output) do
      <<~ADOC
        (*"aic_machining_feature.profile_floor"
        A **profile_floor** is a type of *shape_aspect* that is the representation of the bottom condition for an *outside_profile* *feature_definition*.

        [NOTE]
        --
        A *Profile_floor*, *General_profile_floor* or a *Planar_profile_floor* are defined in ISO 10303-1814 [5] and define the requirement for **profile_floor**.
        --
        *)
      ADOC
    end

    it 'converts html children' do
      ReverseAdoc::Converters.unregister :express_ref
      ReverseAdoc::Converters
        .register(:express_ref,
          Stepmod::Utils::Converters::ExpressRef.new)
      expect(convert).to eq(output)
      ReverseAdoc::Converters.unregister :express_ref
    end
  end
end
