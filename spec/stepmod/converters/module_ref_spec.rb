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

  context "When text is a number with optional prefix" do
    context "table" do
      describe '<module_ref linkend="independent_property_definition:4_entities:table:T1">Table 1</module_ref>' do
        let(:xml_input) do
          '<module_ref linkend="independent_property_definition:4_entities:table:T1">Table 1</module_ref>'
        end

        let(:output) do
          "<<table-independent_property_definition-T1>>"
        end

        it {
          expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip)
        }
      end

      describe '<module_ref linkend="independent_property_definition:4_entities:table:T1">Table (1)</module_ref>' do
        let(:xml_input) do
          '<module_ref linkend="independent_property_definition:4_entities:table:T1">Table (1)</module_ref>'
        end

        let(:output) do
          "<<table-independent_property_definition-T1>>"
        end

        it {
          expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip)
        }
      end

      describe '<module_ref linkend="independent_property_definition:4_entities:table:T1">(1)</module_ref>' do
        let(:xml_input) do
          '<module_ref linkend="independent_property_definition:4_entities:table:T1">(1)</module_ref>'
        end

        let(:output) do
          "<<table-independent_property_definition-T1>>"
        end

        it {
          expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip)
        }
      end
    end

    context "figure" do
      describe '<module_ref linkend="assembly_module_design:4_entities:figure:pudv">Figure 1</module_ref>' do
        let(:xml_input) do
          '<module_ref linkend="assembly_module_design:4_entities:figure:pudv">Figure 1</module_ref>'
        end

        let(:output) do
          "<<figure-assembly_module_design-pudv>>"
        end

        it {
          expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip)
        }
      end

      describe '<module_ref linkend="assembly_module_design:4_entities:figure:pudv">Figure (1)</module_ref>' do
        let(:xml_input) do
          '<module_ref linkend="assembly_module_design:4_entities:figure:pudv">Figure (1)</module_ref>'
        end

        let(:output) do
          "<<figure-assembly_module_design-pudv>>"
        end

        it {
          expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip)
        }
      end

      describe '<module_ref linkend="assembly_module_design:4_entities:figure:pudv">(1)</module_ref>' do
        let(:xml_input) do
          '<module_ref linkend="assembly_module_design:4_entities:figure:pudv">(1)</module_ref>'
        end

        let(:output) do
          "<<figure-assembly_module_design-pudv>>"
        end

        it {
          expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip)
        }
      end
    end
  end

  context "When text is not a number" do
    context "table" do
      describe '<module_ref linkend="independent_property_definition:4_entities:table:T1">This Table</module_ref>' do
        let(:xml_input) do
          '<module_ref linkend="independent_property_definition:4_entities:table:T1">This Table</module_ref>'
        end

        let(:output) do
          "<<table-independent_property_definition-T1,This Table>>"
        end

        it {
          expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip)
        }
      end
    end

    context "figure" do
      describe '<module_ref linkend="assembly_module_design:4_entities:figure:pudv">This Figure</module_ref>' do
        let(:xml_input) do
          '<module_ref linkend="assembly_module_design:4_entities:figure:pudv">This Figure</module_ref>'
        end

        let(:output) do
          "<<figure-assembly_module_design-pudv,This Figure>>"
        end

        it {
          expect(converter.convert(node_for(xml_input)).strip).to eq(output.strip)
        }
      end
    end
  end
end
