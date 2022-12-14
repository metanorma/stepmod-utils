require "spec_helper"
require "stepmod/utils/change_edition"

RSpec.describe Stepmod::Utils::ChangeEdition do
  describe "Instance methods" do
    subject do
      described_class.new(
        version: "2",
        description: "Test Description",
      )
    end

    describe "#additions=" do
      context "when additions is an Array" do
        let(:additions) { [{ type: "ADD", name: "FooBar" }] }

        it do
          expect { subject.additions = additions }
            .to change { subject.additions.count }.from(0).to(1)
        end
      end

      context "when additions is not an Array" do
        let(:additions) { { type: "ADD", name: "FooBar" } }

        it do
          expect { subject.additions = additions }
            .to raise_error("additions must be of type ::Array, Got ::Hash")
        end
      end
    end

    describe "#modifications=" do
      context "when modifications is an Array" do
        let(:modifications) { [{ type: "ADD", name: "FooBar" }] }

        it do
          expect { subject.modifications = modifications }
            .to change { subject.modifications.count }.from(0).to(1)
        end
      end

      context "when modifications is not an Array" do
        let(:modifications) { { type: "ADD", name: "FooBar" } }

        it do
          expect { subject.modifications = modifications }
            .to raise_error("modifications must be of type ::Array, Got ::Hash")
        end
      end
    end

    describe "#deletions=" do
      context "when deletions is an Array" do
        let(:deletions) { [{ type: "ADD", name: "FooBar" }] }

        it do
          expect { subject.deletions = deletions }
            .to change { subject.deletions.count }.from(0).to(1)
        end
      end

      context "when deletions is not an Array" do
        let(:deletions) { { type: "ADD", name: "FooBar" } }

        it do
          expect { subject.deletions = deletions }
            .to raise_error("deletions must be of type ::Array, Got ::Hash")
        end
      end
    end

    describe "#to_h" do
      let(:expected_hash) do
        {
          "version" => "2",
          "description" => "Test Description",
          "additions" => [],
          "modifications" => [],
          "deletions" => [],
        }
      end

      it "should display correct hash" do
        expect(subject.to_h).to eq(expected_hash)
      end
    end

    describe "#validate_type" do
      let(:validate_type) { subject.send(:validate_type, column, value, type) }
      let(:column) { "value" }

      context "when value is of correct type" do
        let(:value) { "abc" }
        let(:type) { String }

        it { expect { validate_type }.not_to raise_error }
      end

      context "when value is not of correct type" do
        let(:value) { 123 }
        let(:type) { String }

        it do
          expect { validate_type }
            .to raise_error("value must be of type ::String, Got ::Integer")
        end
      end
    end
  end
end
