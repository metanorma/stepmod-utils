# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::Def do
  subject(:convert) do
    cleaned_adoc(described_class.new.convert(node_for(input_xml)))
  end

  let(:input_xml) do
    <<~TEXT
        <def>
            Information required for proper control and handling of a specific product or item.
          <note>
            Management data may include information related to scheduling, roles, certifications, approvals, effectivity and life-cycle stages.
          </note>
              <example> An inspection certification indicates that the product has passed inspection and is ready to move to the next step
      in the product life cycle. </example>
        </def>
    TEXT
  end
  let(:output) do
    <<~XML
      Information required for proper control and handling of a specific product or item.

      [NOTE]
      --
      Management data may include information related to scheduling, roles, certifications, approvals, effectivity and life-cycle stages.
      --

      [example]
      ====
      An inspection certification indicates that the product has passed inspection and is ready to move to the next step in the product life cycle.
      ====
    XML
  end

  it "converts para tag into alt block" do
    expect(convert).to eq(output.strip)
  end

  context "when first para tag" do
    let(:input_xml) do
      <<~TEXT
        <def>
          <p>batch</p>
          collection of distinct products that are treated as a single unit
          <example>
            Three thousand bundles of yarn are divided into different groups.
            Each group is submerged in a separate barrel of red dye.
            The group is treated as a lot and assigned a lot number.
            The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots.
            A customer may wish to purchase bundles of the same lot to ensure consistency of the colour.
          </example>
        </def>
      TEXT
    end
    let(:output) do
      <<~XML
        alt:[batch]

        collection of distinct products that are treated as a single unit

        [example]
        ====
        Three thousand bundles of yarn are divided into different groups. Each group is submerged in a separate barrel of red dye. The group is treated as a lot and assigned a lot number. The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots. A customer may wish to purchase bundles of the same lot to ensure consistency of the colour.
        ====
      XML
    end

    it "converts para tag into alt block" do
      expect(convert).to eq(output.strip)
    end

    context "when para is the only definition tag" do
      let(:input_xml) do
        <<~TEXT
          <def>

            <p>batch collection of distinct products that are treated as a single unit</p>


            <example>
              Three thousand bundles of yarn are divided into different groups.
              Each group is submerged in a separate barrel of red dye.
              The group is treated as a lot and assigned a lot number.
              The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots.
              A customer may wish to purchase bundles of the same lot to ensure consistency of the colour.
            </example>
          </def>
        TEXT
      end
      let(:output) do
        "batch collection of distinct products that are treated as a single unit\n\n[example]\n====\nThree thousand bundles of yarn are divided into different groups. Each group is submerged in a separate barrel of red dye. The group is treated as a lot and assigned a lot number. The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots. A customer may wish to purchase bundles of the same lot to ensure consistency of the colour.\n===="
      end

      it "does not convert para tag into alt block" do
        expect(convert).to eq(output.strip)
      end
    end

    context "when para is not the only definition tag" do
      let(:input_xml) do
        <<~TEXT
          <def>

            <p>batch</p>

            some text
            <example>
              Three thousand bundles of yarn are divided into different groups.
              Each group is submerged in a separate barrel of red dye.
              The group is treated as a lot and assigned a lot number.
              The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots.
              A customer may wish to purchase bundles of the same lot to ensure consistency of the colour.
            </example>
          </def>
        TEXT
      end
      let(:output) do
        "alt:[batch]\n\nsome text\n\n[example]\n====\nThree thousand bundles of yarn are divided into different groups. Each group is submerged in a separate barrel of red dye. The group is treated as a lot and assigned a lot number. The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots. A customer may wish to purchase bundles of the same lot to ensure consistency of the colour.\n===="
      end

      it "converts para tag into alt block" do
        expect(convert).to eq(output.strip)
      end
    end
  end
end
