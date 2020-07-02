# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stepmod::Utils::Converters::Def do
  let(:converter) { described_class.new }
  let(:xml_input) do
    <<~TEXT
      <def>
        simple text definistion
        <example>
          Three thousand bundles of yarn are divided into different groups.
          Each group is submerged in a separate barrel of red dye.
          The group is treated as a lot and assigned a lot number.
          The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots.
          A customer may wish to purchase bundles of the same lot to ensure consistency of the colour.
        </example>
        <p>text block to follow</p>
      </def>
    TEXT
  end
  let(:output) do
    "simple text definistion\n[example]\n====\n Three thousand bundles of yarn are divided into different groups. Each group is submerged in a separate barrel of red dye. The group is treated as a lot and assigned a lot number. The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots. A customer may wish to purchase bundles of the same lot to ensure consistency of the colour. \n====\n\n\ntext block to follow"
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
      "alt:[batch]\ncollection of distinct products that are treated as a single unit\n[example]\n====\n Three thousand bundles of yarn are divided into different groups. Each group is submerged in a separate barrel of red dye. The group is treated as a lot and assigned a lot number. The lot number is identified so that conditions causing slight changes in the colour are differentiable among bundles belonging to different lots. A customer may wish to purchase bundles of the same lot to ensure consistency of the colour. \n===="
    end

    it 'converts para tag into alt block' do
      input = node_for(xml_input)
      expect(converter.convert(input).strip).to eq(output.strip)
    end
  end
end
