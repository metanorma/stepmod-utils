# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::ModuleRef do
  let(:converter) { described_class.new }
  let(:xml_input) do
    '<module_ref linkend="product_as_individual:3_definition">individual products</module_ref>'
  end
  let(:output) do
    "{{individual products}}"
  end

  it "when there is semicolum in linked attribute it converts by rules" do
    input = node_for(xml_input)
    expect(converter.convert(input).strip).to eq(output.strip)
  end
end
