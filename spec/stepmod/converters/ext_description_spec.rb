# frozen_string_literal: true

require "spec_helper"
require "support/smrl_converters_setup"

RSpec.describe Stepmod::Utils::Converters::ExtDescription do
  let(:converter) { described_class.new }
  let(:schema) { "schema" }

  it "takes ext_description linkend attribute" do
    input = node_for("<ext_description linkend='#{schema}'></ext_description>")
    expect(converter.convert(input)).to include(%{(*"#{schema}"})
  end

  it "converts html children" do
    input = node_for(
      "<ext_description linkend='#{schema}'><li>foo</li></ext_description>",
    )
    expect(converter.convert(input)).to include("foo\n")
  end
end
