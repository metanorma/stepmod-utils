# frozen_string_literal: true

require 'spec_helper'
require 'reverse_asciidoctor/converters/note'

RSpec.describe ReverseAsciidoctor::Converters::Note do
  let(:converter) { described_class.new }
  let(:xml_input) do
    <<~TEXT
      <note>
      The support solution may include:

      <ul>
        <li> identification of the deployment environment and support solution requirements for
          which the support solution was designed; </li>
        <li> a listing of relevant support drivers; </li>
        <li> a support plan, that identifies necessary tasks to respond to these support drivers,
          and specifies the conditions under which each task falls due; </li>
        <li> justification for the support plan; </li>
        <li> task procedures for necessary tasks; </li>
        <li> identification and quantification of resources needed to achieve necessary tasks,
          including types of person with skill level; </li>
        <li> resource models for necessary tasks; </li>
        <li> product definition data for required resource items. </li>
      </ul>
      </note>
    TEXT
  end
  let(:output) do
    "[NOTE]\n--\nThe support solution may include:\n*  identification of the deployment environment and support solution requirements for which the support solution was designed; \n*  a listing of relevant support drivers; \n*  a support plan, that identifies necessary tasks to respond to these support drivers, and specifies the conditions under which each task falls due; \n*  justification for the support plan; \n*  task procedures for necessary tasks; \n*  identification and quantification of resources needed to achieve necessary tasks, including types of person with skill level; \n*  resource models for necessary tasks; \n*  product definition data for required resource items. \n\n--\n"
  end

  it 'converts note` children' do
    input = node_for(xml_input)
    expect(converter.convert(input).strip).to eq(output.strip)
  end
end
