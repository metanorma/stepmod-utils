# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::ClauseRef do
  subject(:convert) do
    cleaned_adoc(described_class.new.convert(node_for(input_xml)))
  end

  let(:input_xml) do
    '<clause_ref linkend="definition: individual   activity ">individual activity</clause_ref>'
  end
  let(:output) do
    " term:[individual activity] "
  end

  it "compacts and removes any whitespace" do
    expect(convert).to eq(output)
  end
end
