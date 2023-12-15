# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/stepmod/utils/stepmod_file_annotator"

RSpec.describe Stepmod::Utils::StepmodFileAnnotator do
  before do
    ReverseAdoc::Converters.unregister :express_ref
    ReverseAdoc::Converters.register(
      :express_ref,
      Stepmod::Utils::Converters::ExpressRefExpressDescription.new,
    )
  end

  subject do
    stepmod_dir = fixtures_path("stepmod_terms_mock_directory")

    Stepmod::Utils::StepmodFileAnnotator.new(
      stepmod_dir: stepmod_dir,
      express_file: express_file,
    )
  end

  # rubocop:disable Layout/LineLength
  describe "#call" do
    context "when file do not contains (*)" do
      let(:express_file) do
        fixtures_path("stepmod_terms_mock_directory/data/modules/activity/mim.exp")
      end

      let(:expected_output) do
        File.read(fixtures_path("stepmod_terms_mock_directory/data/modules/activity/mim_annotated.exp"))
      end

      it "should return correct annotated text" do
        result = subject.call
        expect(result[:annotated_text]).to eq(expected_output)
        expect(result[:images_references]).to eq({})
      end
    end

    context "when file contains (*)" do
      let(:express_file) do
        fixtures_path("stepmod_terms_mock_directory/data/resources/presentation_appearance_schema/presentation_appearance_schema.exp")
      end

      let(:expected_output) do
        File.read(fixtures_path("stepmod_terms_mock_directory/data/resources/presentation_appearance_schema/presentation_appearance_schema_annotated.exp"))
      end

      let(:expected_images_references) do
        {
          "resource_docs/visual_presentation/box_slant_and_rotate_angle.gif" => "box_slant_and_rotate_angle.gif",
          "resource_docs/visual_presentation/chordal_deviation_and_length.gif" => "chordal_deviation_and_length.gif",
          "resource_docs/visual_presentation/curve_style_curve_pattern.gif" => "curve_style_curve_pattern.gif",
          "resource_docs/visual_presentation/curve_style_with_extension.gif" => "curve_style_with_extension.gif",
          "resource_docs/visual_presentation/fill_area_style_hatching.gif" => "fill_area_style_hatching.gif",
          "resource_docs/visual_presentation/illustration_of_predefined_curve_fonts.gif" => "illustration_of_predefined_curve_fonts.gif",
          "resource_docs/visual_presentation/one_direction_repeat_factor.gif" => "one_direction_repeat_factor.gif",
          "resource_docs/visual_presentation/one_direction_repeat_factor_expression.gif" => "one_direction_repeat_factor_expression.gif",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg1.svg" => "presentation_appearance_schemaexpg1.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg10.svg" => "presentation_appearance_schemaexpg10.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg11.svg" => "presentation_appearance_schemaexpg11.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg2.svg" => "presentation_appearance_schemaexpg2.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg3.svg" => "presentation_appearance_schemaexpg3.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg4.svg" => "presentation_appearance_schemaexpg4.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg5.svg" => "presentation_appearance_schemaexpg5.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg6.svg" => "presentation_appearance_schemaexpg6.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg7.svg" => "presentation_appearance_schemaexpg7.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg8.svg" => "presentation_appearance_schemaexpg8.svg",
          "resource_docs/visual_presentation/presentation_appearance_schemaexpg9.svg" => "presentation_appearance_schemaexpg9.svg",
          "resource_docs/visual_presentation/squared_or_rounded.gif" => "squared_or_rounded.gif",
          "resource_docs/visual_presentation/text_style_with_mirror.gif" => "text_style_with_mirror.gif",
          "resource_docs/visual_presentation/two_direction_repeat_factor.gif" => "two_direction_repeat_factor.gif",
          "resource_docs/visual_presentation/two_direction_repeat_factor_expression.gif" => "two_direction_repeat_factor_expression.gif",
        }
      end

      it "should return correct annotated text" do
        result = subject.call
        expect(result[:annotated_text]).to eq(expected_output)
        expect(result[:images_references]).to eq(expected_images_references)
      end
    end
  end

  describe "#convert_from_description_text" do
    let(:express_file) { fixtures_path("stepmod_terms_mock_directory/data/modules/activity/arm.exp") }
    let(:description_file) { fixtures_path("stepmod_terms_mock_directory/data/modules/activity/arm_descriptions.xml") }

    let(:xml_description) do
      <<~DESCRIPTION
        <ext_description linkend="Activity_arm.Activity">
          An <b>Activity</b> is the identification of the occurrence of an action that  has taken place, is taking place, or is expected to take place in the
          future. The procedure executed during that <b>Activity</b> is identified with the <express_ref linkend="activity_method:arm:Activity_method_arm.Activity_method"/> that is referred to by the <b>chosen_method</b> attribute.

          <example>
            Change, distilling, design, a process to drill a hole, and a task such as training someone, are examples of activities.
          </example>

          <note number="1">
            Status information identifying the level of completion of each activity may be provided within an instance of <express_ref linkend="Activity:arm:Activity_arm.Activity_status"/>.
          </note>

          <note number="2">
            The items that are affected by an <b>Activity</b>, for example as input or output, may be identified within an instance of <express_ref linkend="Activity:arm:Activity_arm.Applied_activity_assignment"/>.
          </note>
        </ext_description>
      DESCRIPTION
    end

    let(:expected_output) do
      <<~OUTPUT

        (*"Activity_arm.Activity"
        An **Activity** is the identification of the occurrence of an action that has taken place, is taking place, or is expected to take place in the future. The procedure executed during that **Activity** is identified with the <<express:Activity_method_arm.Activity_method,Activity_method>> that is referred to by the **chosen_method** attribute.
        *)

        (*"Activity_arm.Activity.__example"
        Change, distilling, design, a process to drill a hole, and a task such as training someone, are examples of activities.
        *)

        (*"Activity_arm.Activity.__note"
        Status information identifying the level of completion of each activity may be provided within an instance of <<express:Activity_arm.Activity_status,Activity_status>>.
        *)

        (*"Activity_arm.Activity.__note"
        The items that are affected by an *Activity*, for example as input or output, may be identified within an instance of <<express:Activity_arm.Applied_activity_assignment,Applied_activity_assignment>>.
        *)
      OUTPUT
    end

    it "is expected to produce correct output" do
      description = Nokogiri::XML(xml_description).xpath("ext_description").first
      output = subject.send(:convert_from_description_text, description_file, description)

      expect(output).to eq(expected_output)
    end
  end
  # rubocop:enable Layout/LineLength
end
