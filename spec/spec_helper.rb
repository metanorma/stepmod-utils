require "bundler/setup"
require 'byebug'
require "stepmod/utils"
require "stepmod/utils/concept"
require 'stepmod/utils/stepmod_definition_converter'
require 'stepmod/utils/smrl_description_converter'
require 'stepmod/utils/smrl_resource_converter'
require 'stepmod/utils/converters/ext_description'
require 'stepmod/utils/converters/ext_descriptions'
require 'stepmod/utils/converters/express_g'
require 'stepmod/utils/converters/schema_diag'
require 'stepmod/utils/converters/express_g'

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

def cleaned_adoc(adoc)
  adoc.gsub(/ \n/, "\n")
end
