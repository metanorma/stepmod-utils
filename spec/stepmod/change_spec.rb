require "spec_helper"
require "stepmod/utils/change"

RSpec.describe Stepmod::Utils::Change do
  describe "Instance methods" do
    subject do
      described_class.new(
        stepmod_dir: stepmod_dir,
        schema_name: "test_schema",
        type: type,
      )
    end

    let(:stepmod_dir) { fixtures_path("stepmod_terms_mock_directory") }

    describe "#resource?" do
      context "when is a resource" do
        let(:type) { "schema" }

        it { expect(subject.resource?).to be(true) }
      end

      context "when is a module" do
        let(:type) { "arm" }

        it { expect(subject.resource?).to be(false) }
      end
    end

    describe "#module?" do
      context "when is a module" do
        let(:type) { "arm" }

        it { expect(subject.module?).to be(true) }
      end

      context "when is a resource" do
        let(:type) { "schema" }

        it { expect(subject.module?).to be(false) }
      end
    end

    describe "#add_change_edition" do
      let(:type) { "arm" }

      let(:change_edition) do
        {
          "version" => "2",
          "description" => "Test Description",
          "additions" => [{ "type" => "ADD", "name" => "FooBar" }],
          "modifications" => [{ "type" => "MODIFY", "name" => "FooBar" }],
          "deletions" => [{ "type" => "DELETE", "name" => "FooBar" }],
        }
      end

      it "should add change_edition to change" do
        expect { subject.add_change_edition(change_edition) }
          .to change { subject.change_editions.count }.from(0).to(1)
      end
    end

    describe "#to_h" do
      let(:type) { "arm" }
      let(:resource) { false }

      let(:change_edition) do
        {
          "version" => "2",
          "description" => "Test Description",
          "additions" => [{ "type" => "ADD", "name" => "FooBar" }],
          "modifications" => [{ "type" => "MODIFY", "name" => "FooBar" }],
          "deletions" => [{ "type" => "DELETE", "name" => "FooBar" }],
        }
      end

      let(:expected_output) do
        {
          "schema" => "test_schema",
          "change_edition" => [
            {
              "version" => "2",
              "description" => "Test Description",
              "additions" => [{ "type" => "ADD", "name" => "FooBar" }],
              "modifications" => [{ "type" => "MODIFY", "name" => "FooBar" }],
              "deletions" => [{ "type" => "DELETE", "name" => "FooBar" }],
            },
          ],
        }
      end

      it "should output change in correct hash format" do
        subject.add_change_edition(change_edition)
        expect(subject.to_h).to eq(expected_output)
      end
    end

    describe "#filepath" do
      let(:filepath) { subject.send(:filepath, type) }

      context "when module" do
        let(:type) { "arm" }
        let(:resource) { false }

        let(:expected_path) do
          "#{stepmod_dir}/data/modules/test_schema/arm.changes.yaml"
        end

        it { expect(filepath).to eq(expected_path) }
      end

      context "when resource" do
        let(:type) { "schema" }
        let(:resource) { true }

        let(:expected_path) do
          "#{stepmod_dir}/data/resources/test_schema/test_schema.changes.yaml"
        end

        it { expect(filepath).to eq(expected_path) }
      end
    end

    describe "#filename" do
      let(:filename) { subject.send(:filename, type) }

      context "when module" do
        let(:resource) { false }

        describe "when filename should be used without extension" do
          let(:type) { "changes" }

          let(:expected_path) do
            "changes.yaml"
          end

          it { expect(filename).to eq(expected_path) }
        end

        describe "when filename should be used with .changes extension" do
          let(:type) { "arm" }

          let(:expected_path) do
            "arm.changes.yaml"
          end

          it { expect(filename).to eq(expected_path) }
        end
      end

      context "when resource" do
        let(:type) { "schema" }
        let(:resource) { true }

        let(:expected_path) do
          "test_schema.changes.yaml"
        end

        it { expect(filename).to eq(expected_path) }
      end
    end

    describe "#base_folder" do
      let(:base_folder) { subject.send(:base_folder) }

      context "when module" do
        let(:type) { "arm" }
        let(:resource) { false }

        it { expect(base_folder).to eq("modules") }
      end

      context "when resource" do
        let(:type) { "schema" }
        let(:resource) { true }

        it { expect(base_folder).to eq("resources") }
      end
    end
  end
end
