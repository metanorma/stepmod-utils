require "bundler/setup"
require "stepmod/utils"
require "stepmod/utils/concept"
require "stepmod/utils/stepmod_definition_converter"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def node_for(html)
  Nokogiri::HTML.parse(html).root.child.child
end

def fixtures_path(path)
  File.join(File.expand_path("./fixtures", __dir__), path)
end

def resource_annotated_exp_path(name)
  resources_path = "stepmod_terms_mock_directory/data/resources"
  fixtures_path("#{resources_path}/#{name}/#{name}_annotated.exp")
end

def cleaned_adoc(adoc)
  adoc.gsub(/ \n/, "\n")
end
