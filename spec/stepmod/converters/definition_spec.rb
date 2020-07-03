# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stepmod::Utils::Converters::Definition do
  let(:converter) { described_class.new }
  let(:xml_input) do
    <<~TEXT
      <definition>
          <term>boundary representation solid model  </term>
          <def>
            <p> B-rep </p>
          type of geometric model in which the size and shape of a solid is
          defined in terms of the faces, edges
          and vertices which make up its boundary
        </def>
      </definition>
    TEXT
  end
  let(:output) do
    "=== boundary representation solid model\n\nalt:[B-rep]\n\ntype of geometric model in which the size and shape of a solid is defined in terms of the faces, edges and vertices which make up its boundary"
  end

  it 'converts complex children block by rules' do
    input = node_for(xml_input)
    expect(converter.convert(input)).to eq(output)
  end

  context 'when there is clause_ref children tags' do
    let(:xml_input) do
      <<~TEXT
        <definition>
          <term id="class_of_activity">class of activity</term>
          <def>
          class that has only
          <!-- <clause_ref linkend="3_definition:individual_activity">individual activities</clause_ref> -->

            <clause_ref linkend="definition:individual activity">individual activity</clause_ref>
          as members

          <example number="1">
          'Distilling' is a class of activity that is reference data held in a reference data library.
          The classification of the individual activity 'Distill batch_27 on 2006-05-19' as
          'distilling' specifies what it is.
          </example>
        </def>
        </definition>
      TEXT
    end
    let(:output) do
      "=== class of activity\n\nclass that has only term:[individual activity] as members\n\n[example]\n====\n'Distilling' is a class of activity that is reference data held in a reference data library. The classification of the individual activity 'Distill batch\\_27 on 2006-05-19' as 'distilling' specifies what it is.\n===="
    end

    it 'converts para tag into alt block' do
      input = node_for(xml_input)
      expect(converter.convert(input)).to eq(output)
    end
  end

  context 'when there is blank line at the start of block' do
    let(:xml_input) do
      <<~TEXT
        <def>
          <note>
            <p>The support solution may include:The support solution may include:</p>
          </note>
          <example>
            <p>Three thousand bundles of yarn are divided into different groups.Each group is submerged in a separate barrel of red dye.
            </p>
          </example>
        </def>
      TEXT
    end
    let(:output) do
      "[NOTE]\n--\nThe support solution may include:The support solution may include:\n--\n\n[example]\n====\nThree thousand bundles of yarn are divided into different groups.Each group is submerged in a separate barrel of red dye.\n===="
    end


    it 'removes any blank lines supplied and preceding lines' do
      input = node_for(xml_input)
      expect(converter.convert(input).strip).to eq(output.strip)
    end
  end

  context 'when there is a list inside note block' do
    let(:xml_input) do
      <<~TEXT
        <def>
          <note>
            The support solution may include:The support solution may include:
            <ul><li>one</li><li>two</li><li>three</li></ul>
          </note>
        </def>
      TEXT
    end
    let(:output) do
      "[NOTE]\n--\nThe support solution may include:The support solution may include: \n\n* one\n* two\n* three\n--"
    end


    it 'removes any blank lines supplied and preceding lines' do
      input = node_for(xml_input)
      byebug
      expect(converter.convert(input).strip).to eq(output.strip)
    end
  end
end
