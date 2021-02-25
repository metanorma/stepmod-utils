# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stepmod::Utils::Converters::Definition do
  subject(:convert) { cleaned_adoc(described_class.new.convert(node_for(input_xml))) }

  let(:input_xml) do
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
    <<~XML
      === boundary representation solid model

      alt:[B-rep]

      type of geometric model in which the size and shape of a solid is defined in terms of the faces, edges and vertices which make up its boundary
    XML
  end

  it 'converts complex children block by rules' do
    expect(convert).to eq(output.strip)
  end

  context 'when there is clause_ref children tags' do
    let(:input_xml) do
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
      "=== class of activity\n\nclass that has only\n// <clause_ref linkend=\"3_definition:individual_activity\">individual activities</clause_ref>\nterm:[individual activity] as members\n\n[example]\n====\n'Distilling' is a class of activity that is reference data held in a reference data library. The classification of the individual activity 'Distill batch_27 on 2006-05-19' as 'distilling' specifies what it is.\n===="
    end

    it 'converts para tag into alt block' do
      expect(convert).to eq(output)
    end
  end

  context 'when there is blank line at the start of block' do
    let(:input_xml) do
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
      expect(convert.strip).to eq(output)
    end
  end

  context 'when there is a list inside note block' do
    let(:input_xml) do
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
      expect(convert).to eq(cleaned_adoc(output))
    end
  end

  context 'when additional text tags' do
    let(:input_xml) do
      <<~TEXT
        <definition>
          <term>curve  </term>
            <def>
            <ul><li>one</li><li>two</li><li>three</li></ul>
            set of mathematical points which is the image, in two- or
            three-dimensional space, of a continuous function defined over a
            connected subset
            of
            the real line R
            <sup>1</sup>
            , and which is not a single point
          </def>
        </definition>
      TEXT
    end
    let(:output) do
      "=== curve\n\n* one\n* two\n* three\n\nset of mathematical points which is the image, in two- or three-dimensional space, of a continuous function defined over a connected subset of the real line R ^1^ , and which is not a single point"
    end


    it 'does not get block indention' do
      expect(convert.strip).to eq(output)
    end
  end
end
