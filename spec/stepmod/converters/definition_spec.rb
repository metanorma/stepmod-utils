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
    "\n=== boundary representation solid model \nalt:[ B-rep ]\ntype of geometric model in which the size and shape of a solid is defined in terms of the faces, edges and vertices which make up its boundary\n"
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
      "\n=== class of activity\nclass that has only\n term:[definition:individual activity] as members\n\n[example]\n====\n 'Distilling' is a class of activity that is reference data held in a reference data library. The classification of the individual activity 'Distill batch\\_27 on 2006-05-19' as 'distilling' specifies what it is. \n====\n"
    end

    it 'converts para tag into alt block' do
      input = node_for(xml_input)
      expect(converter.convert(input)).to eq(output)
    end
  end
end
