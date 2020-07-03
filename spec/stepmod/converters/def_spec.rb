# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stepmod::Utils::Converters::Def do
  let(:converter) { described_class.new }
  let(:xml_input) do
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
    "Information required for proper control and handling of a specific product or item.\n\n[NOTE]\n--\nManagement data may include information related to scheduling, roles, certifications, approvals, effectivity and life-cycle stages.\n--\n\n[example]\n====\nAn inspection certification indicates that the product has passed inspection and is ready to move to the next step in the product life cycle.\n===="
  end

  it 'converts para tag into alt block' do
    input = node_for(xml_input)
    expect(converter.convert(input).strip).to match(output.strip)
  end

  context 'when first para tag' do
    let(:xml_input) do
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
      "alt:[batch]\n\ncollection of distinct products that are treated as a single unit\n\n[example]\n====\nThree thousand bundles of yarn are divided into different groups. Each group is submerged in a separate barrel of red dye. The group is treated as a lot and assigned a lot number. The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots. A customer may wish to purchase bundles of the same lot to ensure consistency of the colour.\n===="
    end

    it 'converts para tag into alt block' do
      input = node_for(xml_input)
      expect(converter.convert(input).strip).to eq(output.strip)
    end

    context 'when para is the only definition tag' do
      let(:xml_input) do
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

      it 'does not convert para tag into alt block' do
        input = node_for(xml_input)
        expect(converter.convert(input).strip).to eq(output.strip)
      end
    end

    context 'when para is not the only definition tag' do
      let(:xml_input) do
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

      it 'converts para tag into alt block' do
        input = node_for(xml_input)
        expect(converter.convert(input).strip).to eq(output.strip)
      end
    end
  end
end
