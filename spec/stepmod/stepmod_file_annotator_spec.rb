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
    resource_docs_cache_file = fixtures_path("resource_docs_cache.json")

    Stepmod::Utils::StepmodFileAnnotator.new(
      stepmod_dir: stepmod_dir,
      express_file: express_file,
      resource_docs_cache_file: resource_docs_cache_file,
    )
  end

  describe "#call" do
    let(:express_file) do
      fixtures_path("stepmod_terms_mock_directory/data/modules/activity/mim.exp")
    end

    let(:expected_output) do
      File.read(fixtures_path("stepmod_terms_mock_directory/data/modules/activity/mim_annotated.exp"))
    end

    it "shout return correct annotated text" do
      output = subject.call
      expect(output).to eq(expected_output)
    end
  end

  # rubocop:disable Layout/LineLength
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
